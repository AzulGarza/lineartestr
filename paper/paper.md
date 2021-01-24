---
title: 'lineartestr: An R package for testing the linear specification of a model'
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
 - name: Instituto Tecnológico Autónomo de México
   index: 1
 #- name: Institution 2
  # index: 2
date: 15 Jun 2020
bibliography: paper.bib

# Optional fields if submitting to a AAS journal too, see this blog post:
# https://blog.joss.theoj.org/2018/12/a-new-collaboration-with-aas-publishing
#aas-doi: 10.3847/xxxxx <- update this with the DOI from AAS once you know it.
#aas-journal: Astrophysical Journal <- The name of the AAS journal.
---

# Summary

Many econometric models use the underlying assumption that the relationship between endogenous and exogenous variables is linear. This is the case of models such as difference-in-differences, fixed effects, regression discontinuity design among others that are particularly useful inferring causal relationships [@angrist_mostly_2008]. As a part of the hypothesis imposed to the models, the linear relationship between variables must be contrasted in order to guarantee the validity of the research results. To this end we have developed `lineartestr` for R [@r] with a novel and robust approach.

# Statement of need

The package `lineartestr` implements a novel approach developed by Domínguez and Lobato [@lobato] that tests the linear specification of a model trough a bootstrap test with the main function `dominguez_lobato_test()`. This approach generalizes well known specification tests such as Ramsey's RESET (also implemented with the function `reset_test()`) and as the authors conclude this new test is more robust than others. This is the main difference from other R packages that implement linearity tests such as `lmtest` [@lmtest] and `car` [@car]. Therefore this new package provides to researchers with a new robust tool to their research arsenal.


## Domínguez-Lobato test

The Domínguez-Lobato approach tests the linear specification of a model. It means that tests the null hypothesis,

$$
H_0: y = \beta^T x + u.
$$

Where $y$ is the target variable, $x$ are control variables and $u$ is the model error. In their work, Domínguez and Lobato proposed two statistics to test this hypothesis [@lobato]. Consider a collection $\{(y_i, x_i)\}$ of size n from $(y, x)$. First, the Cramer von Mises (CvM) statistic given by

$$
C_n = \frac{1}{n^2} \sum_{l=1}^n \left[ \sum_{i=1}^n \hat{u}_i I(\hat{y}_i \leq \hat{y}_l)\right].
$$  

Where $\hat{y}_j$ are the fitted values of the endogenous variable and $\hat{u}_i = y_i - \hat{y}_i$. Second, the Kolmogorov Smirnov (KS) statistic given by

$$
K_n = \max_l \left| \sum_{i=1}^n \hat{u}_i I(\hat{y}_i \leq \hat{y}_l) \right|.
$$

With this statistics the authors propose a wild bootstrap test described by the following steps:

1. Fit the linear model $y_i  = \alpha^T x_i + u_i$ and collect the fitted values $\hat{y}_i$.
2. With the actual residuals $\hat{u}_i = y_i - \hat{y}_i$ calculate $C_n$ or $K_n$.
3. Generate a collection $\{V^b_i\}$ of size $n$ of bounded random variables independent and identically distributed with mean zero and unit variance. With this observations construct a new endogenous variable,

$$
y^b_i = \hat{y}_i + \hat{u}_i*V^b_i.
$$

4. Adjust a new model $y^b_i = \beta^{bT} x_i + u^b_i$. With $\hat{u}^b_i = y^b_i - \hat{y}^b_i$ calculate $C^b_n$ or $K^b_n$ as corresponds.

5. Generate a collection $\{C^b_n\}$ or $\{K^b_n\}$ of size $B$ repeating 2. Each collection $\{V^b_i\}$ is independent of each other.

6. Calculate the $(1-\alpha)$-quantile from  ${C^b_n}$ or ${K^b_n}$: $C_{[1-\alpha]}$ or $K_{[1-\alpha]}$. Finally reject the null hypothesis at the $\alpha$ nominal level when $C_n > C_{[1-\alpha]}$ and when $K_n > K_{[1-\alpha]}$, respectively.

The algorithm works because the statistic $C_n$ and $C^b_n$ share the same asymptotic distribution under the null hypothesis (for almost all samples) [@lobato].

## `lineartestr` package

The `lineartestr` package includes the function `dominguez_lobato_test` which performs the algorithm developed by Domínguez and Lobato [@lobato]. This function receives the four main parameters of the algorithm:

1. `model`: a fitted linear model. The package can handle any fitted linear model compatible with the `update()` function such as `stats::lm()` [@r] or `lfe::felm()` [@lfe]. Also the function can receive ARMA models (which are linear models) fitted from `forecast::Arima()` [@forecast].

2. `distribution`: a function name from which the collection $\{V^b_i\}$ will be calculated. By default, the package uses a standard normal random variable (`'rnorm'` that calls `stats::rnorm` [@r]) but other random variables with mean zero and unit variance can be used. In particular, the package includes three special functions that satisfies this requirements: `'rmammen_cont'`, `'rmammen_point'` [@mammen] and `'rrademacher'` [@rrademacher].

3. `statistic`: `'cvm_value'` to use the CvM statistic or `'kmv_value'` to use the KS statistic.

4. `times`: number of bootstrap repetitions ($B$).

### Parallel processing

The wild bootstrap approach of this test can be time consuming. However, `lineartestr` can process this repetitions trough parallel processing using the `parallel` package [@r]. This can be done as simply as setting the `n_cores` parameter of the `dominguez_lobato_test` function with the number of desired workers to carry out this tasks.

### Ramsey's RESET test

The Ramsey's RESET (Regression Equation Specification Error Test) test [@ramsey] is a widely known tool that can be used too to test the specification of a linear model. This method works as follows,

1. Fit the linear model $y_i  = \alpha^T x_i + u_i$ and collect the fitted values $\hat{y}_i$.

2. Choose $k\geq3$ and estimate the following,

$$
y_i = \alpha^T x_i + \gamma_1 \hat{y}_i^2 + ... + \gamma_{k-1} \hat{y}_i^k + u_i.
$$    

3. Use a Wald test [@wald] to contrast the following null hypothesis. If this null hypothesis is rejected, then the hypothesis of the model's linearity is also rejected,

$$
H_0: \gamma_1 = \gamma_2 =...= \gamma_{k-1} = 0.
$$

For completeness the RESET test is also implemented trough the `reset_test` function which uses the custom `wald_test` function to carry out the null hypothesis test. Like the `dominguez_lobato_test` function, it receives a fitted linear model.

### Plot functions

The package `lineartestr` also contains special functions to plot each of the tests (`plot_dl_test` for the `dominguez_lobato_test`). This plots can be useful to get a visual description of the statistic's distribution, the statistic's value and the test's critical values.

# Acknowledgements

We thank Daniela Baltazar Cerros and Kin Gutiérrez Olivares for their support and feedback.

# References
