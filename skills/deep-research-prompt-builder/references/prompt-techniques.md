# Prompt Engineering Techniques Reference

Quick reference for advanced prompting techniques to incorporate into research prompts.

## Chain-of-Thought (CoT)

**When to use:** Complex reasoning, multi-step problems, mathematical/logical analysis

**Implementation:**
- Add "Let's think step-by-step"
- Include "Show your reasoning process"
- Request "Break this down into logical steps"

**Example enhancement:**
```
Before providing conclusions, walk through your reasoning:
1. Establish baseline facts
2. Identify relationships and patterns
3. Draw logical inferences
4. Validate conclusions against evidence
```

## Self-Consistency

**When to use:** High-stakes research, controversial topics, data-heavy analysis

**Implementation:**
```
For each major finding:
- Verify through multiple sources
- Note agreement/disagreement levels
- Flag any single-source claims
- Indicate confidence: High (3+ sources agree), Medium (2 sources), Low (single source)
```

## Role-Based Framing

**When to use:** Specialized domains requiring expert perspective

**Effective roles by domain:**
- Technical: "Senior software architect with 10+ years experience"
- Business: "Management consultant specializing in [industry]"
- Academic: "Research scientist with expertise in [field]"
- Product: "Consumer insights analyst"

## Multi-Path Exploration

**When to use:** Open-ended questions, strategy development, problem-solving

**Implementation:**
```
Explore this question from three angles:
1. [Conventional approach]
2. [Alternative perspective]
3. [Contrarian view]

Then synthesize insights across all paths.
```

## Evidence Hierarchy

**When to use:** Academic research, fact-checking, controversial topics

**Hierarchy (highest to lowest):**
1. Peer-reviewed meta-analyses
2. Peer-reviewed studies
3. Pre-prints and technical reports
4. Industry white papers
5. Expert opinions
6. News articles
7. User-generated content

**Prompt addition:**
```
Prioritize evidence by credibility. Note source type for all claims:
[META], [STUDY], [REPORT], [INDUSTRY], [EXPERT], [NEWS], [USER]
```

## Structured Decomposition

**When to use:** Complex topics, large scope research

**Template:**
```
Decompose [TOPIC] into components:
1. Core concepts (define key terms)
2. Relationships (how parts connect)
3. Dynamics (how things change/interact)
4. Implications (what this means)
5. Applications (how it's used)
```

## Boundary Setting

**When to use:** Prevent scope creep, focus research

**Essential boundaries:**
- Temporal: "Focus on developments from [DATE] forward"
- Geographic: "Limited to [REGION/COUNTRY]"
- Domain: "Within context of [SPECIFIC FIELD]"
- Depth: "Surface-level overview" vs "Technical deep-dive"
- Exclusions: "Exclude [SPECIFIC ASPECTS]"

## Output Optimization Patterns

**Synthesis-First:**
```
1. Key takeaways (3-5 bullets)
2. Supporting details
3. Full analysis
```

**Narrative Structure:**
```
1. Context/background
2. Current state
3. Challenges/opportunities
4. Future outlook
5. Recommendations
```

**Decision-Support:**
```
1. Options identified
2. Evaluation criteria
3. Comparative analysis
4. Trade-offs
5. Recommendation with rationale
```

## Common Enhancements by Research Type

**Trend Analysis:**
"Track evolution over time, identify inflection points, project future trajectory"

**Competitive Analysis:**
"Map competitive landscape, identify differentiators, assess relative strengths"

**Literature Review:**
"Synthesize findings, identify consensus/debates, highlight gaps"

**Technical Evaluation:**
"Assess feasibility, identify dependencies, evaluate alternatives"

**Market Research:**
"Size the opportunity, profile segments, identify drivers/barriers"