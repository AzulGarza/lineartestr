---
title: 'lineartestr: An R package to test the linear specification of a model'
tags:
  - R
  - linear-specification
  - linear-regression
  - dominguez-lobato-test
  - wild-bootstrap
  - reset-test
authors:
  - name: Federico Garza Ramírez
    orcid: 0000-0001-7015-8186
    affiliation: "1" # (Multiple affiliations must be quoted)
  #- name: Author Without ORCID
  #  affiliation: 2
affiliations:
 - name: ITAM
   index: 1
 #- name: Institution 2
  # index: 2
date: 10 May 2017
bibliography: paper.bib

# Optional fields if submitting to a AAS journal too, see this blog post:
# https://blog.joss.theoj.org/2018/12/a-new-collaboration-with-aas-publishing
#aas-doi: 10.3847/xxxxx <- update this with the DOI from AAS once you know it.
#aas-journal: Astrophysical Journal <- The name of the AAS journal.
---

# Summary

Many econometric models uses the underlying assumption that the relationship between endogenous and exogenuos variables is linear. This is the case of models such as difference-in-differences, fixed effects, regression discontinuity design among others that are particuarly useful to characterize causal relationships. As a part of the hypothesis imposed to the models, the linear relationship between the variables must be tested in order to guarantee a good design. The package lineartestr implements a novel approach developed by Domínguez and Lobato [@lobato] that tests the linear specification of a model. This approach generalizes well known specifications tests such as Ramsey's RESET (Regression Equation Specification Error Test).


## Domínguez-Lobato test

The Domínguez-Lobato approach tests the null hypothesis

$$
H_0: y=\beta^T x + u
$$

Algorithm:

1. With the actual residuals $u_i = y_i - \hat{y}_i$ calculate the test statistic $C_n$ or $K_n$.
2. Generate a collection ${V^b_i}$ of size $n$ of bounded random variables independent and indentically distributed with mean zero and unit variance. With this observations construct a new endogenous variable: 

$$
y^b_i = \hat{y}_i + u_i*V^b_i 
$$ 

Also adjust a new model $y^b_i = \beta_b^T x_i + u^b_i$. With $\hat{u}^b_i = y^b_i - \hat{y}^b_i$ calculate $C^b_n$ or $K^b_n$ as corresponds.

3. Generate a collection ${C^b_n}$ or ${K^b_n}$ of size $B$ repeating 2. Each collection ${V^b_i}$ is independent of each other. 
4. Calculate the $(1-\alpha)$-quantile from  ${C^b_n}$ or ${K^b_n}$: $C_{[1-\alpha]}$ or $K_{[1-\alpha]}$. Finally reject the null hypothesis at the $\alpha$ nominal level when $C_n > C_{[1-\alpha]}$ and when $K_n > K_{[1-\alpha]}$, respectively. 

# Acknowledgements

# References
