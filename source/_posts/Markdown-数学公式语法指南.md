---
title: Markdown 数学公式语法指南
date: 2025-12-07 18:37:17
tags: Markdown
---

# Markdown 数学公式语法指南

Markdown 中使用 LaTeX 语法来编写数学公式.

## 常见运算符

### 基本算术运算符
| 运算符 | LaTeX 语法 | 示例 | 效果 |
|--------|-------------|------|------|
| 加号 | `+` | `a + b` | $a + b$ |
| 减号 | `-` | `a - b` | $a - b$ |
| 乘号 | `\times` | `a \times b` | $a \times b$ |
| 点乘 | `\cdot` | `a \cdot b` | $a \cdot b$ |
| 除号 | `\div` | `a \div b` | $a \div b$ |
| 分数 | `\frac{a}{b}` | `\frac{a}{b}` | $\frac{a}{b}$ |
| 平方根 | `\sqrt{x}` | `\sqrt{x}` | $\sqrt{x}$ |
| n次方根 | `\sqrt[n]{x}` | `\sqrt[3]{x}` | $\sqrt[3]{x}$ |
| 对数 | `\log` | `\log x` | $\log x$ |
| 自然对数 | `\ln` | `\ln x` | $\ln x$ |
| 以a为底对数 | `\log_a b` | `\log_a b` | $\log_a b$ |

### 取模运算

Markdown/LaTeX 中有多种方式表示取模运算：

| 运算符 | LaTeX 语法 | 示例 | 效果 | 说明 |
|--------|-------------|------|------|------|
| 取模 | `\bmod` | `a \bmod b` | $a \bmod b$ | 二元取模运算符 |
| 同余 | `\pmod` | `a \equiv b \pmod{n}` | $a \equiv b \pmod{n}$ | 模 n 同余 |
| 同余 | `\mod` | `a \equiv b \mod n` | $a \equiv b \mod n$ | 同余关系 |
| 函数形式 | `\operatorname{mod}` | `\operatorname{mod}(a, b)` | $\operatorname{mod}(a, b)$ | 函数形式 |

## 逻辑运算符

| 运算符 | LaTeX 语法 | 示例 | 效果 |
|--------|-------------|------|------|
| 与 | `\land` 或 `\wedge` | `a \land b` | $a \land b$ |
| 或 | `\lor` 或 `\vee` | `a \lor b` | $a \lor b$ |
| 非 | `\lnot` 或 `\neg` | `\lnot a` | $\lnot a$ |
| 异或 | `\oplus` | `a \oplus b` | $a \oplus b$ |
| 同或 | `\odot` | `a \odot b` | $a \odot b$ |
| 蕴含 | `\rightarrow` 或 `\implies` | `a \rightarrow b` | $a \rightarrow b$ |
| 等价 | `\leftrightarrow` 或 `\iff` | `a \leftrightarrow b` | $a \leftrightarrow b$ |
| 对于所有 | `\forall` | `\forall x \in \mathbb{R}` | $\forall x \in \mathbb{R}$ |
| 存在 | `\exists` | `\exists x \in \mathbb{R}` | $\exists x \in \mathbb{R}$ |

### 上下标
| 类型 | LaTeX 语法 | 示例 | 效果 |
|------|-------------|------|------|
| 上标 | `^` | `x^2` | $x^2$ |
| 下标 | `_` | `x_1` | $x_1$ |
| 组合 | `^{}_{}` | `x^{2}_{1}` | $x^{2}_{1}$ |

### 关系运算符
| 运算符 | LaTeX 语法 | 示例 | 效果 |
|--------|-------------|------|------|
| 等于 | `=` | `a = b` | $a = b$ |
| 不等于 | `\neq` | `a \neq b` | $a \neq b$ |
| 约等于 | `\approx` | `a \approx b` | $a \approx b$ |
| 大于 | `>` | `a > b` | $a > b$ |
| 小于 | `<` | `a < b` | $a < b$ |
| 大于等于 | `\geq` | `a \geq b` | $a \geq b$ |
| 小于等于 | `\leq` | `a \leq b` | $a \leq b$ |
| 正比于 | `\propto` | `a \propto b` | $a \propto b$ |

### 求和、积分、极限
| 运算符 | LaTeX 语法 | 示例 | 效果 |
|--------|-------------|------|------|
| 求和 | `\sum` | `\sum_{i=1}^{n} i` | $\sum_{i=1}^{n} i$ |
| 积分 | `\int` | `\int_{a}^{b} f(x)dx` | $\int_{a}^{b} f(x)dx$ |
| 极限 | `\lim` | `\lim_{x \to \infty} f(x)` | $\lim_{x \to \infty} f(x)$ |
| 乘积 | `\prod` | `\prod_{i=1}^{n} i` | $\prod_{i=1}^{n} i$ |

### 希腊字母
| 字母 | LaTeX 语法 | 示例 | 效果 |
|------|-------------|------|------|
| α | `\alpha` | `\alpha` | $\alpha$ |
| β | `\beta` | `\beta` | $\beta$ |
| γ | `\gamma` | `\gamma` | $\gamma$ |
| Δ | `\Delta` | `\Delta` | $\Delta$ |
| π | `\pi` | `\pi$` | $\pi$ |
| θ | `\theta` | `\theta` | $\theta$ |
| μ | `\mu` | `\mu$` | $\mu$ |
| σ | `\sigma` | `\sigma` | $\sigma$ |
| ω | `\omega` | `\omega` | $\omega$ |

### 集合运算符
| 运算符 | LaTeX 语法 | 示例 | 效果 |
|--------|-------------|------|------|
| 属于 | `\in` | `a \in A` | $a \in A$ |
| 不属于 | `\notin` | `a \notin A` | $a \notin A$ |
| 子集 | `\subset` | `A \subset B` | $A \subset B$ |
| 真子集 | `\subseteq` | `A \subseteq B` | $A \subseteq B$ |
| 并集 | `\cup` | `A \cup B` | $A \cup B$ |
| 交集 | `\cap` | `A \cap B` | $A \cap B$ |
| 空集 | `\emptyset` | `\emptyset` | $\emptyset$ |

### 函数表达式

#### 常用数学函数
| 函数 | LaTeX 语法 | 示例 | 效果 |
|------|-------------|------|------|
| 正弦 | `\sin` | `\sin x` | $\sin x$ |
| 余弦 | `\cos` | `\cos x` | $\cos x$ |
| 正切 | `\tan` | `\tan x` | $\tan x$ |
| 指数 | `\exp` | `\exp(x)` | $\exp(x)$ |
| 最大值 | `\max` | `\max(a, b)` | $\max(a, b)$ |
| 最小值 | `\min` | `\min(a, b)` | $\min(a, b)$ |

### 矩阵和行列式
```markdown
$$
\begin{matrix}
a & b \\
c & d
\end{matrix}
$$

$$
\begin{pmatrix}
a & b \\
c & d
\end{pmatrix}
$$

$$
\begin{vmatrix}
a & b \\
c & d
\end{vmatrix}
$$
```

效果：
$$
\begin{matrix}
a & b \\
c & d
\end{matrix}
$$

$$
\begin{pmatrix}
a & b \\
c & d
\end{pmatrix}
$$

$$
\begin{vmatrix}
a & b \\
c & d
\end{vmatrix}
$$

### 括号和定界符
| 类型 | LaTeX 语法 | 示例 | 效果 |
|------|-------------|------|------|
| 花括号 | `\{ \}` | `\{a+b\}` | $\{a+b\}$ |
| 自适应括号 | `\left( \right)` | `\left(\frac{a}{b}\right)` | $\left(\frac{a}{b}\right)$ |
