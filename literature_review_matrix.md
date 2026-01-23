# Literature Review Matrix

## GoalBuddy - Little Kickers Coach Companion Application

This matrix summarizes the academic literature and technical documentation reviewed for the development of GoalBuddy, an AI-powered mobile application for youth football academy management.

---

| Code | Author(s), Year | Title | Research Questions | Methodology | Key Findings | Relevance to Project | Limitations |
|------|----------------|-------|-------------------|-------------|--------------|---------------------|-------------|
| 1 | Bandura, A. (1977) | Social Learning Theory | How do individuals acquire new behaviors through observation and imitation? | Theoretical framework; Qualitative analysis of behavioral acquisition through modeling | Children learn primarily through observation, imitation, and modeling; visual demonstration is more effective than verbal instruction for motor skill acquisition | Provides theoretical foundation for visual drill animations; justifies why coaches need visual aids to demonstrate drills to young children (1.5-8 years) | Dated publication (1977); general theory not specific to sports or digital applications |
| 2 | Conra, M. A., et al. (2021) | Game-based soccer training models for children aged 6-8 years | Can game-based training models improve locomotor and manipulative motor skills in 6-8 year olds? | R&D method (Borg & Gall); Quantitative; n=30 children; TGMD-2 motor assessment tool | 33 game-based models developed; significant improvement in both locomotor and manipulative motion skills | Directly validates game-based approach for Little Kickers age groups; supports structured drill-based session templates | Focused on specific age range (6-8 years); limited to Indonesian context |
| 3 | Côté, J. & Hancock, D. J. (2016) | Evidence-based policies for youth sport programs | What policies should guide youth sport program development? | Systematic review; Policy analysis; Evidence synthesis from multiple studies | Ages 2-6 should focus on fundamental movement skills through play-based learning; sport-specific training inappropriate for young children | Validates Little Kickers curriculum structure (age groups 1.5-8 years); supports "Fun Phase" approach in session templates | Policy-focused rather than empirical; limited practical implementation guidance |
| 4 | Cui, L., et al. (2021) | Document AI: Benchmarks, Models and Applications | How can AI models extract structured information from documents? | Technical review; Benchmarking of document understanding models; arXiv preprint | Modern AI achieves high accuracy in document structure understanding; multimodal models outperform text-only approaches | Provides technical foundation for Gemini PDF extraction feature; validates AI approach to lesson plan processing | Preprint (not peer-reviewed); general document AI, not sports-specific |
| 5 | Diekhoff, H. & Greve, S. (2023) | Digital technology in game-based approaches: Video tagging in football in PE | How do students perceive digital technology (video tagging) in football PE? | Qualitative; n=131 students; TGfU method; Videocatch app; thematic analysis | Digital tools useful for conflict resolution and tactical understanding; mixed reception of "camera child" role | Supports integration of digital tools in football coaching; validates technology-enhanced training approaches | Focused on older students (not toddlers); context-specific to German PE classes |
| 6 | Dorsch, T. E., et al. (2021) | Parent involvement in youth sport: A systematic review | What is the impact of parent involvement on youth sport outcomes? | Systematic literature review; Analysis of parent engagement studies | Parent involvement positively correlates with child engagement, skill development, and program retention | Justifies parent dashboard feature; supports real-time progress visibility for parents | Review methodology limits causal claims; heterogeneous study quality |
| 7 | Grygus, I., et al. (2024) | Methodological aspects of developing motor skills in children of different ages during football club activities | What are optimal methods for motor skill training by age in football? | Literature review (2014-2024); PRISMA guidelines; Expert consultation | Age-specific training essential; game-based exercises (ages 4-10) more effective than traditional drills; AI integration promising | Validates age-group differentiation in Little Kickers; supports AI-enhanced training tools | Literature review (not primary research); AI recommendations need empirical validation |
| 8 | Hurtado-Almonacid, J., et al. (2024) | Development of Basic Motor Skills from 3 to 10 Years of Age: Comparison by Sex and Age Range in Chilean Children | How do motor skills develop across ages 3-10, and do differences exist by sex? | Cross-sectional; Quantitative; n=328 children; TGMD-2 assessment tool | Majority of children in poor to low-average motor categories; motor age often lags chronological age; minimal sex differences | Emphasizes urgent need for early motor intervention; validates importance of structured football programs for young children | Single geographic sample (Chile); cross-sectional design limits developmental conclusions |
| 9 | Moreno, D. M. N., et al. (2021) | Utilization of a Mobile Application for Motor Skill Assessment in Children | Can mobile apps effectively assess fine motor skills in children? | Quantitative; n=45 children; Custom Android app; Comparison with MABC-2 standardized test | App successfully captured movement precision data; error rates decreased with age; user-friendly interface achieved | Validates mobile app approach for motor skill tracking; supports digital attendance and progress monitoring features | Focused on fine motor (not gross motor); limited sample size |
| 10 | Ratten, V. (2020) | Sport technology: A commentary | How is technology transforming sports management and operations? | Commentary/Review; Analysis of digital transformation trends in sports | Mobile apps, cloud computing, and data analytics are key enablers; digital tools improve efficiency and stakeholder engagement | Establishes theoretical context for digital academy management; supports technology adoption in youth sports | Commentary format; limited empirical data |
| 11 | Semartiana, N., et al. (2022) | A systematic literature review of gamification for children: Game elements, purposes, and technologies | What gamification elements are effective for children's learning? | Systematic Literature Review; 20 articles analyzed; 4 databases | Points, levels, leaderboards most common; mobile apps preferred platform (55%); gamification increases motivation and engagement | Informs UI/UX design decisions; supports badge system and progress tracking features | Limited year range reviewed; broad focus (not sports-specific) |
| 12 | Shepherd, H. A., et al. (2021) | The impact of COVID-19 on youth sport | How did COVID-19 affect youth sports participation and operations? | Mixed methods review; Analysis of pandemic impact studies | Accelerated digital adoption; highlighted gaps in existing digital solutions; increased demand for remote communication tools | Contextualizes need for digital academy management; supports push notification and communication features | Pandemic-specific context may not generalize post-COVID |
| 13 | Ste-Marie, D. M., et al. (2012) | Observation interventions for motor skill learning and performance | How do observation-based interventions affect motor skill learning? | Meta-analysis; Review of 60+ studies on observational learning | Visual demonstrations significantly improve skill acquisition; video/animation more effective than verbal instruction alone | Provides empirical support for drill animation feature; validates visual learning approach for young athletes | Meta-analysis limitations; heterogeneous study populations |
| 14 | Wiersma, L. D. & Sherman, C. P. (2005) | Volunteer youth sport coaches' perspectives of coaching education | What are coaches' needs and perspectives on coaching education? | Qualitative; Interviews with volunteer coaches; Thematic analysis | Coaches need accessible, practical training resources; time constraints major barrier; prefer visual/practical over theoretical | Supports coach-centric design; validates need for efficient session management tools and visual drill aids | Dated (2005); focused on volunteer coaches; US context |
| 15 | Williams, A. M. & Hodges, N. J. (2005) | Practice, instruction and skill acquisition in soccer | What instructional methods optimize soccer skill acquisition? | Review of motor learning research; Soccer-specific analysis | Visual demonstrations critical for skill acquisition; practice structure affects learning; age-appropriate instruction essential | Directly supports drill visualization feature; validates structured session template approach | Review article; soccer-focused but principles apply broadly |
| 16 | Wu, W. (2018) | React Native vs Flutter: A comparison | How do React Native and Flutter compare for mobile development? | Technical comparison; Performance benchmarking; Feature analysis | Flutter offers superior animation performance (Skia engine); better for graphics-intensive apps; single codebase advantage | Justifies Flutter selection for GoalBuddy; validates framework choice for drill animation rendering | Blog post (not peer-reviewed); rapid framework evolution may date findings |
| 17 | Zhang, Y., et al. (2024) | MiniMovers: An initial pilot and feasibility study to investigate the impact of a mobile application on children's motor skills and parent support for physical development | Can a mobile app improve children's motor skills with parental involvement? | Mixed methods pilot; n=8 children; TGMD-3 assessment; Parent interviews | Significant motor skill improvements (running, jumping, kicking); high parent-child enjoyment; increased parent knowledge | Directly validates mobile app approach for motor development; supports parent dashboard and progress tracking features | Very small sample (n=8); no control group; short intervention period |

---

## Summary Statistics

| Metric | Value |
|--------|-------|
| **Total Papers Reviewed** | 17 |
| **Empirical Studies** | 9 |
| **Review/Meta-Analysis** | 5 |
| **Technical/Commentary** | 3 |
| **Publication Range** | 1977-2024 |

---

## Most Relevant Studies to GoalBuddy Project

| Study | Primary Contribution |
|-------|---------------------|
| Conra et al. (2021) | Validates game-based training models for children 6-8 years |
| Zhang et al. (2024) | Supports mobile app + parent involvement approach |
| Grygus et al. (2024) | Validates age-specific training and AI integration |
| Hurtado-Almonacid et al. (2024) | Demonstrates need for early motor intervention |
| Semartiana et al. (2022) | Informs gamification and UI/UX design |
| Ste-Marie et al. (2012) | Provides evidence for visual/animation-based learning |

---

## Thematic Groupings

### Motor Development & Youth Sports
- Bandura (1977), Conra et al. (2021), Côté & Hancock (2016), Grygus et al. (2024), Hurtado-Almonacid et al. (2024), Ste-Marie et al. (2012), Williams & Hodges (2005)

### Mobile Applications & Technology
- Cui et al. (2021), Moreno et al. (2021), Ratten (2020), Semartiana et al. (2022), Wu (2018), Zhang et al. (2024)

### Digital Tools in Sports Education
- Diekhoff & Greve (2023), Shepherd et al. (2021), Wiersma & Sherman (2005)

### Parental Involvement
- Dorsch et al. (2021), Zhang et al. (2024)

---

## Full References

1. Bandura, A. (1977). Social Learning Theory. Prentice Hall.

2. Conra, M. A., Marlina Siregar, N., & Setiakarnawijaya, Y. (2021). Game-based soccer training models for children aged 6-8 years. *Gladi: Jurnal Ilmu Keolahragaan*, 12(04), 281–290. https://doi.org/10.21009/gjik.124.07

3. Côté, J., & Hancock, D. J. (2016). Evidence-based policies for youth sport programs. *International Journal of Sport Policy and Politics*, 8(1), 51-65.

4. Cui, L., et al. (2021). Document AI: Benchmarks, Models and Applications. *arXiv preprint*.

5. Diekhoff, H., & Greve, S. (2023). Digital technology in game-based approaches: Video tagging in football in PE. *Physical Education and Sport Pedagogy*, 1–13. https://doi.org/10.1080/17408989.2023.2256758

6. Dorsch, T. E., et al. (2021). Parent involvement in youth sport: A systematic review. *Sport, Exercise, and Performance Psychology*, 10(3), 345-363.

7. Grygus, I., Gamma, T., Godlevskyi, P., Zhuk, M., & Zukow, W. (2024). Methodological aspects of developing motor skills in children of different ages during football club activities. *Journal of Education Health and Sport*, 64, 55525. https://doi.org/10.12775/jehs.2024.64.55525

8. Hurtado-Almonacid, J., Reyes-Amigo, T., Yáñez-Sepúlveda, R., Cortés-Roco, G., Oñate-Navarrete, C., Olivares-Arancibia, J., & Páez-Herrera, J. (2024). Development of Basic Motor Skills from 3 to 10 Years of Age: Comparison by Sex and Age Range in Chilean Children. *Children*, 11(6), 715. https://doi.org/10.3390/children11060715

9. Moreno, D. M. N., Vázquez-Araújo, F. J., Castro, P. M., Costa, J. V., Dapena, A., & Doniz, L. G. (2021). Utilization of a Mobile Application for Motor Skill Assessment in Children. *Applied Sciences*, 11(2), 663. https://doi.org/10.3390/app11020663

10. Ratten, V. (2020). Sport technology: A commentary. *Journal of High Technology Management Research*, 31(1), 100383.

11. Semartiana, N., Putri, A., & Rosmansyah, Y. (2022). A systematic literature review of gamification for children: Game elements, purposes, and technologies. *International Conference on Information Science and Technology Innovation (ICoSTEC)*, 1(1), 72–76. https://doi.org/10.35842/icostec.v1i1.12

12. Shepherd, H. A., et al. (2021). The impact of COVID-19 on youth sport. *Frontiers in Sports and Active Living*, 3, 630075.

13. Ste-Marie, D. M., et al. (2012). Observation interventions for motor skill learning and performance. *Psychonomic Bulletin & Review*, 19(2), 193-220.

14. Wiersma, L. D., & Sherman, C. P. (2005). Volunteer youth sport coaches' perspectives of coaching education. *Sport, Education and Society*, 10(2), 191-213.

15. Williams, A. M., & Hodges, N. J. (2005). Practice, instruction and skill acquisition in soccer. *Journal of Sports Sciences*, 23(6), 637-650.

16. Wu, W. (2018). React Native vs Flutter: A comparison. *Medium Engineering Blog*.

17. Zhang, Y., Wainwright, N., Goodway, J. D., John, A., Stevenson, A., Thomas, K., Jenkins, S., Layas, F., & Piper, K. (2024). MiniMovers: An initial pilot and feasibility study to investigate the impact of a mobile application on children's motor skills and parent support for physical development. *Children*, 11(1), 99. https://doi.org/10.3390/children11010099
