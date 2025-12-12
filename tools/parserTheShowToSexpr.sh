#!/usr/bin/env bash
# Usage:
#   cat example1.tslang | ./tslang_to_sexpr.sh

awk '
BEGIN {
    ntokens = 0
    pos = 1
}

function trim(s){sub(/^[ \t\r\n]+/,"",s);sub(/[ \t\r\n]+$/,"",s);return s}

function add_token(kind, val){ ntokens++; tok_kind[ntokens]=kind; tok_val[ntokens]=val }

function is_space(c){ return (c ~ /[ \t\r]/) }
function is_alpha(c){ return (c ~ /[A-Za-z_]/) }
function is_digit(c){ return (c ~ /[0-9]/) }

function tokenize_line(line,    i,c,buf){
    i=1
    # line comments starting with "desnote"
    if (substr(line,1,7)=="desnote") {
        add_token("COMMENT", trim(line))
        return
    }
    while (i<=length(line)) {
        c=substr(line,i,1)
        if (is_space(c)) { i++; continue }

        # punctuation / operators
        if (c ~ /[:(),\[\]=*+\-]/) {
            # "->"
            if (c=="-" && substr(line,i+1,1)==">") {
                add_token("ARROW", "->"); i+=2; continue
            }
            # "+="
            if (c=="+" && substr(line,i+1,1)=="=") {
                add_token("OP", "+="); i+=2; continue
            }
            add_token("PUNC", c); i++; continue
        }


        # string literal
        if (c=="\"") {
            buf=c; i++
            while (i<=length(line)) {
                c=substr(line,i,1)
                buf=buf c
                if (c=="\"") break
                i++
            }
            add_token("STRING", buf); i++; continue
        }

        # number
        if (is_digit(c)) {
            buf=c; i++
            while (i<=length(line)) {
                c=substr(line,i,1)
                if (!is_digit(c)) break
                buf=buf c; i++
            }
            add_token("INT", buf); continue
        }

        # identifier / keyword
        if (is_alpha(c)) {
            buf=c; i++
            while (i<=length(line)) {
                c=substr(line,i,1)
                if (!(is_alpha(c) || is_digit(c))) break
                buf=buf c; i++
            }
            add_token("IDENT", buf); continue
        }

        i++
    }
}

function peek_kind(){ return tok_kind[pos] }
function peek_val(){ return tok_val[pos] }
function consume(){ return tok_val[pos++] }

function emit_symbol(name){ return "SSymbol \"" name "\"" }
function emit_int(v){ return "SInt " v }
function emit_string(v){ return "SString " v }   # v still has the quotes

# ------------- expression to SExpr -------------

function parse_primary(    k,v,expr,expr2,first){
    k=peek_kind(); v=peek_val()
    if (k=="INT")   { consume(); return emit_int(v) }
    if (k=="STRING"){ consume(); return emit_string(v) }
    if (k=="IDENT") {
        consume()
        expr = emit_symbol(v)
        # function call: name(...)
        if (peek_val()=="(") {
            consume() # (
            expr2 = "SList [" expr  # (name ...)
            first=0
            while (peek_val()!=")") {
                if (!first) expr2 = expr2 ", "
                expr2 = expr2 parse_expr()
                first=0
                if (peek_val()==",") consume()
            }
            consume() # )
            expr2 = expr2 "]"
            return expr2
        }
        return expr
    }
    return emit_symbol("UNKNOWN")
}

function parse_postfix(    expr,idx){
    expr = parse_primary()
    # array indexing a[0][1]...
    while (peek_val()=="[") {
        consume()
        idx = parse_expr()
        consume() # ]
        expr = "SList [" emit_symbol("index") ", " expr ", " idx "]"
    }
    return expr
}

function parse_term(    expr,op,right){
    expr = parse_postfix()
    while (peek_val()=="*") {
        op=consume()
        right=parse_postfix()
        expr="SList [" emit_symbol(op) ", " expr ", " right "]"
    }
    return expr
}

function parse_expr(    expr,op,right){
    expr = parse_term()
    while (peek_val()=="+" || peek_val()=="-") {
        op=consume()
        right=parse_term()
        expr="SList [" emit_symbol(op) ", " expr ", " right "]"
    }
    return expr
}

# ------------- block & statements -------------

function parse_var_decl(    name,init,typeS){
    name=consume()  # IDENT
    if (peek_val()=="=") {
        consume()
        init=parse_expr()
    } else {
        init=emit_symbol("unit")
    }
    consume() # "->"
    typeS=consume()
    return "SList [" \
           emit_symbol("eric") ", " \
           emit_symbol(name) ", " \
           emit_symbol(typeS) ", " \
           init \
           "]"
}

function parse_if(    cond,thenS,elseS){
    consume() # "("
    cond=parse_expr()
    consume() # ")"
    consume() # ":"
    thenS = emit_symbol("block")
    if (peek_val()=="deschelse") {
        consume(); consume() # ":"
        elseS = emit_symbol("block")
    } else {
        elseS = emit_symbol("unit")
    }
    return "SList [" emit_symbol("if") ", " cond ", " thenS ", " elseS "]"
}

function parse_for(    hdr){
    hdr=""
    while (peek_val() != ":") {
        if (hdr != "") hdr = hdr " "
        hdr = hdr peek_val()
        consume()
    }
    consume()  # ":"
    return "SList [" emit_symbol("aer") ", " emit_symbol(hdr) "]"
}

function parse_return_like(    expr){
    if (peek_kind() ~ /(INT|STRING|IDENT)/) {
        expr=parse_expr()
        return "SList [" emit_symbol("return") ", " expr "]"
    }
    return "SList [" emit_symbol("return") "]"
}

function parse_stmt(    k,v,lhs,rhs,op,name,exprs,first){
    k=peek_kind(); v=peek_val()

    if (v=="eric") { consume(); return parse_var_decl() }
    if (v=="deschodt"){ consume(); return parse_return_like() }
    if (v=="erif"){ consume(); return parse_if() }
    if (v=="aer"){ consume(); return parse_for() }
    if (v=="darius"){ consume(); return "SList [" emit_symbol("while") ", " emit_symbol("cond") ", " emit_symbol("block") "]" }
    if (v=="deschreak"){ consume(); return emit_symbol("break") }
    if (v=="deschontinue"){ consume(); return emit_symbol("continue") }

    if (v=="peric"){
        # print call as generic call
        name = consume()
        consume() # "("
        exprs = ""
        first=1
        while (peek_val()!=")") {
            if (!first) exprs = exprs ", "
            exprs = exprs parse_expr()
            first=0
            if (peek_val()==",") consume()
        }
        consume() # ")"
        return "SList [" \
               emit_symbol("call") ", " \
               emit_symbol(name) ", " \
               "SList [" exprs "]" \
               "]"
    }

    if (k=="COMMENT") {
        v = consume()
        return "SList [" emit_symbol("comment") ", SString \"" v "\" ]"
    }

    # assignment or expression
    if (k=="IDENT") {
        lhs=parse_postfix()
        if (peek_val()=="=" || peek_val()=="+=") {
            op=consume()
            rhs=parse_expr()
            return "SList [" emit_symbol(op) ", " lhs ", " rhs "]"
        }
        return lhs
    }

    consume()
    return emit_symbol("UNKNOWN-STMT")
}

function parse_param_list(    params,name,typeS,first){
    params=""; first=1
    while (peek_val()!=")") {
        if (!first) params=params ", "
        name=consume()
        consume() # "->"
        typeS=consume()
        params=params "SList [" emit_symbol(name) ", " emit_symbol(typeS) "]"
        if (peek_val()==",") consume()
        first=0
    }
    consume() # ")"
    return "SList [" params "]"
}

# very simple block: eat statements until next top‑level decl/comment
function parse_block(    stmts,firstStmt,savePos,v,stmt){
    stmts = ""
    firstStmt = 1
    while (pos <= ntokens) {
        savePos = pos
        v = peek_val()
        if (v == "Deschodt" || v == "destruct" || v == "desnum" || v == "desnote") {
            # next top‑level
            break
        }
        stmt = parse_stmt()
        if (!firstStmt) stmts = stmts ", "
        stmts = stmts stmt
        firstStmt = 0
    }
    return "SList [" stmts "]"
}

function parse_func_decl(    name,params,retT,body){
    name=consume()
    consume() # "("
    params=parse_param_list()
    consume() # "->"
    retT=consume()
    body = parse_block()
    return "SList [" \
           emit_symbol("fun") ", " \
           emit_symbol(name) ", " \
           params ", " \
           emit_symbol(retT) ", " \
           body \
           "]"
}

function parse_struct_decl(    name,fields,fname,ftype,first){
    name=consume()
    consume() # ":"
    fields=""; first=1
    while (pos<=ntokens && peek_val()!="Deschodt" && peek_val()!="destruct" && peek_val()!="desnum") {
        if (peek_kind()=="IDENT") {
            if (!first) fields=fields ", "
            fname=consume()
            consume() # "->"
            ftype=consume()
            fields=fields "SList [" emit_symbol(fname) ", " emit_symbol(ftype) "]"
            first=0
        } else consume()
    }
    return "SList [" emit_symbol("struct") ", " emit_symbol(name) ", SList [" fields "] ]"
}

function parse_enum_decl(    name){
    name=consume()
    return "SList [" emit_symbol("enum") ", " emit_symbol(name) "]"
}

function parse_toplevel(    v){
    v=peek_val()
    if (v=="Deschodt"){ consume(); return parse_func_decl() }
    if (v=="destruct"){ consume(); return parse_struct_decl() }
    if (v=="desnum"){ consume(); return parse_enum_decl() }
    # desnote lines are already tokenized as COMMENT,
    # so they go through parse_stmt -> comment node
    return parse_stmt()
}

{
    tokenize_line($0)
}

END {
    pos=1
    first=1
    printf("SList [")
    while (pos<=ntokens) {
        node=parse_toplevel()
        if (!first) printf(", ")
        printf("%s", node)
        first=0
    }
    printf("]\n")
}
'
