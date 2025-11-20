#!/usr/bin/env bash

# Usage:
#   cat input.scm | ./sexpr_to_ast.sh

awk '
function trim(s) { sub(/^[ \t\r\n]+/, "", s); sub(/[ \t\r\n]+$/, "", s); return s }

# --- tokenizer ---
function tokenize(line,    i,c,tok) {
    for (i=1; i<=length(line); i++) {
        c = substr(line,i,1)
        if (c ~ /[()]/) {
            tokens[++ntokens] = c
        } else if (c ~ /[ \t]/) {
            # skip
        } else {
            tok=""
            while (i<=length(line)) {
                c2 = substr(line,i,1)
                if (c2 ~ /[() \t]/) { i--; break }
                tok = tok c2
                i++
            }
            tokens[++ntokens] = tok
        }
    }
}

# --- parser: parse one S-expression ---
function parse_expr(    t,expr) {
    t = tokens[pos]
    pos++

    if (t == "(") {
        expr="SList ["
        first=1
        while (tokens[pos] != ")") {
            subexpr = parse_expr()
            if (!first) expr = expr ", "
            expr = expr subexpr
            first=0
        }
        pos++ # skip ")"
        expr = expr "]"
        return expr
    }

    # atom
    if (t == "#t") return "SBool True"
    if (t == "#f") return "SBool False"

    if (t ~ /^-?[0-9]+$/) return "SInt " t

    return "SSymbol \"" t "\""
}

BEGIN {
    input=""
}
{
    input = input " " $0
}
END {
    gsub(/\(/," ( ",input)
    gsub(/\)/," ) ",input)
    ntokens=0
    tokenize(input)
    pos=1

    first_top=1
    while (pos <= ntokens) {
        expr = parse_expr()
        if (!first_top) printf(", ")
        printf("%s", expr)
        first_top=0
    }
    printf("\n")
}'
