#!/usr/bin/env python3
"""
Prompt Validator - Checks if a research prompt contains all recommended components
"""

import sys
import re

class PromptValidator:
    def __init__(self):
        self.required_sections = [
            "Research Objective",
            "Context and Scope", 
            "Research Requirements",
            "Evidence Standards",
            "Analysis Framework",
            "Output Structure",
            "Quality Instructions"
        ]
        
        self.recommended_elements = [
            "Primary questions",
            "Secondary considerations",
            "Explicitly exclude",
            "Source types",
            "Reasoning Approach",
            "Critical Evaluation"
        ]
        
        self.results = {
            'missing_required': [],
            'missing_recommended': [],
            'word_count': 0,
            'has_scope': False,
            'has_boundaries': False,
            'has_specifics': False
        }
    
    def validate(self, prompt_text):
        """Validate a research prompt for completeness"""
        
        # Check required sections
        for section in self.required_sections:
            if section not in prompt_text:
                self.results['missing_required'].append(section)
        
        # Check recommended elements
        for element in self.recommended_elements:
            if element.lower() not in prompt_text.lower():
                self.results['missing_recommended'].append(element)
        
        # Word count
        self.results['word_count'] = len(prompt_text.split())
        
        # Check for scope indicators
        scope_keywords = ['boundaries', 'timeframe', 'geographic', 'scope', 'focus on', 'limited to']
        self.results['has_scope'] = any(kw in prompt_text.lower() for kw in scope_keywords)
        
        # Check for specificity
        specific_indicators = ['specifically', 'exactly', 'must', 'should', 'require']
        self.results['has_specifics'] = any(ind in prompt_text.lower() for ind in specific_indicators)
        
        return self.results
    
    def print_report(self):
        """Print validation report"""
        print("\n" + "="*50)
        print("RESEARCH PROMPT VALIDATION REPORT")
        print("="*50)
        
        # Required sections
        if self.results['missing_required']:
            print("\n⚠️  MISSING REQUIRED SECTIONS:")
            for section in self.results['missing_required']:
                print(f"  • {section}")
        else:
            print("\n✅ All required sections present")
        
        # Recommended elements
        if self.results['missing_recommended']:
            print("\n⚠️  MISSING RECOMMENDED ELEMENTS:")
            for element in self.results['missing_recommended']:
                print(f"  • {element}")
        else:
            print("\n✅ All recommended elements present")
        
        # Quality indicators
        print("\n📊 QUALITY INDICATORS:")
        print(f"  • Word count: {self.results['word_count']} {'✅' if self.results['word_count'] > 200 else '⚠️  (consider adding more detail)'}")
        print(f"  • Has scope definition: {'✅' if self.results['has_scope'] else '⚠️'}")
        print(f"  • Has specific instructions: {'✅' if self.results['has_specifics'] else '⚠️'}")
        
        # Overall score
        score = self._calculate_score()
        print(f"\n📈 OVERALL QUALITY SCORE: {score}/100")
        
        if score >= 90:
            print("🌟 Excellent prompt! Ready for deep research.")
        elif score >= 70:
            print("👍 Good prompt. Consider addressing missing elements for better results.")
        elif score >= 50:
            print("⚠️  Prompt needs improvement. Add missing sections for better research quality.")
        else:
            print("❌ Prompt needs significant enhancement. Review the template and add required sections.")
        
        print("\n" + "="*50 + "\n")
    
    def _calculate_score(self):
        """Calculate overall quality score"""
        score = 100
        
        # Deduct for missing required sections (10 points each)
        score -= len(self.results['missing_required']) * 10
        
        # Deduct for missing recommended elements (5 points each)
        score -= len(self.results['missing_recommended']) * 5
        
        # Deduct if too short
        if self.results['word_count'] < 200:
            score -= 10
        
        # Deduct for missing quality indicators
        if not self.results['has_scope']:
            score -= 5
        if not self.results['has_specifics']:
            score -= 5
        
        return max(0, score)


def main():
    if len(sys.argv) < 2:
        print("Usage: python validate_prompt.py <prompt_file.txt>")
        print("Or pipe prompt text: echo 'prompt text' | python validate_prompt.py")
        sys.exit(1)
    
    # Read prompt text
    if sys.argv[1] == '-':
        # Read from stdin
        prompt_text = sys.stdin.read()
    else:
        # Read from file
        try:
            with open(sys.argv[1], 'r') as f:
                prompt_text = f.read()
        except FileNotFoundError:
            print(f"Error: File '{sys.argv[1]}' not found")
            sys.exit(1)
    
    # Validate
    validator = PromptValidator()
    validator.validate(prompt_text)
    validator.print_report()
    
    # Return exit code based on score
    score = validator._calculate_score()
    sys.exit(0 if score >= 70 else 1)


if __name__ == "__main__":
    main()