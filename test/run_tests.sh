#!/bin/bash
# GLaDOS LISP Interpreter Test Suite
# Usage: ./run_tests.sh [glados_path]

GLADOS="${1:-./glados}"
PASS=0
FAIL=0
TOTAL=0

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================"
echo "    GLaDOS LISP Test Suite"
echo "========================================"
echo ""

# Function to run a test that should succeed (exit code 0)
run_success_test() {
    local file=$1
    local expected=$2
    local desc=$(head -1 "$file" | sed 's/^; Test: //')
    
    TOTAL=$((TOTAL + 1))
    output=$("$GLADOS" < "$file" 2>&1)
    exit_code=$?
    
    # Get last non-empty line of output
    result=$(echo "$output" | grep -v '^$' | tail -1)
    
    if [ $exit_code -eq 0 ] && [ "$result" = "$expected" ]; then
        echo -e "${GREEN}✓${NC} $file"
        PASS=$((PASS + 1))
    else
        echo -e "${RED}✗${NC} $file"
        echo "  Expected: $expected (exit 0)"
        echo "  Got: $result (exit $exit_code)"
        FAIL=$((FAIL + 1))
    fi
}

# Function to run a test that should fail (exit code 84)
run_error_test() {
    local file=$1
    
    TOTAL=$((TOTAL + 1))
    output=$("$GLADOS" < "$file" 2>&1)
    exit_code=$?
    
    if [ $exit_code -eq 84 ]; then
        echo -e "${GREEN}✓${NC} $file (error correctly detected)"
        PASS=$((PASS + 1))
    else
        echo -e "${RED}✗${NC} $file"
        echo "  Expected: exit code 84"
        echo "  Got: exit code $exit_code"
        FAIL=$((FAIL + 1))
    fi
}

# Check if glados exists
if [ ! -x "$GLADOS" ]; then
    echo -e "${RED}Error: $GLADOS not found or not executable${NC}"
    echo "Usage: $0 [path_to_glados]"
    exit 1
fi

echo -e "${YELLOW}=== Atoms Tests ===${NC}"
run_success_test "files_test/atoms/integer_positive.scm" "42"
run_success_test "files_test/atoms/integer_negative.scm" "-42"
run_success_test "files_test/atoms/integer_zero.scm" "0"
run_success_test "files_test/atoms/boolean_true.scm" "#t"
run_success_test "files_test/atoms/boolean_false.scm" "#f"
run_success_test "files_test/atoms/symbol_simple.scm" "42"

echo ""
echo -e "${YELLOW}=== List Parsing Tests ===${NC}"
run_success_test "files_test/lists/list_with_spaces.scm" "3"
run_success_test "files_test/lists/list_with_tabs.scm" "3"
run_success_test "files_test/lists/list_with_newlines.scm" "3"

echo ""
echo -e "${YELLOW}=== Error Handling Tests (should exit 84) ===${NC}"
run_error_test "files_test/errors/unbound_variable.scm"
run_error_test "files_test/errors/missing_close_paren.scm"
run_error_test "files_test/errors/extra_close_paren.scm"
run_error_test "files_test/errors/division_by_zero.scm"
run_error_test "files_test/errors/modulo_by_zero.scm"
run_error_test "files_test/errors/wrong_type_arg_plus.scm"
run_error_test "files_test/errors/wrong_type_arg_less.scm"
run_error_test "files_test/errors/call_non_procedure.scm"
run_error_test "files_test/errors/define_missing_value.scm"
run_error_test "files_test/errors/define_missing_symbol.scm"
run_error_test "files_test/errors/lambda_missing_body.scm"
run_error_test "files_test/errors/lambda_missing_args.scm"
run_error_test "files_test/errors/if_missing_else.scm"
run_error_test "files_test/errors/if_missing_then.scm"
run_error_test "files_test/errors/if_missing_condition.scm"
run_error_test "files_test/errors/lambda_too_few_args.scm"
run_error_test "files_test/errors/lambda_too_many_args.scm"
run_error_test "files_test/errors/define_number_as_symbol.scm"
run_error_test "files_test/errors/lambda_non_symbol_param.scm"
run_error_test "files_test/errors/nested_unbound_variable.scm"

echo ""
echo -e "${YELLOW}=== Lambda Tests ===${NC}"
run_success_test "files_test/lambda/lambda_immediate_call.scm" "3"
run_success_test "files_test/lambda/lambda_no_args_call.scm" "42"
run_success_test "files_test/lambda/lambda_assigned.scm" "7"
run_success_test "files_test/lambda/lambda_nested.scm" "10"
run_success_test "files_test/lambda/lambda_closure.scm" "15"
run_success_test "files_test/lambda/lambda_shadowing.scm" "7"
run_success_test "files_test/lambda/lambda_many_params.scm" "50"
run_success_test "files_test/lambda/lambda_curried_call.scm" "12"
run_success_test "files_test/lambda/lambda_as_argument.scm" "8"
run_success_test "files_test/lambda/lambda_complex_body.scm" "90"
run_success_test "files_test/lambda/lambda_returns_bool.scm" "#t"

echo ""
echo -e "${YELLOW}=== Define/Binding Tests ===${NC}"
run_success_test "files_test/define/define_simple.scm" "42"
run_success_test "files_test/define/define_expression.scm" "10"
run_success_test "files_test/define/define_boolean_true.scm" "#t"
run_success_test "files_test/define/define_boolean_false.scm" "#f"
run_success_test "files_test/define/define_multiple.scm" "30"
run_success_test "files_test/define/define_chained.scm" "100"
run_success_test "files_test/define/define_named_function.scm" "7"
run_success_test "files_test/define/define_named_function_no_args.scm" "42"
run_success_test "files_test/define/define_named_function_single.scm" "25"
run_success_test "files_test/define/define_named_function_many.scm" "15"
run_success_test "files_test/define/define_redefine.scm" "200"
run_success_test "files_test/define/define_negative.scm" "-42"
run_success_test "files_test/define/define_zero.scm" "0"
run_success_test "files_test/define/define_complex_expr.scm" "21"

echo ""
echo -e "${YELLOW}=== Builtin Functions Tests ===${NC}"
run_success_test "files_test/builtins/add_simple.scm" "5"
run_success_test "files_test/builtins/add_negative.scm" "-1"
run_success_test "files_test/builtins/add_zero.scm" "5"
run_success_test "files_test/builtins/sub_simple.scm" "3"
run_success_test "files_test/builtins/sub_negative.scm" "7"
run_success_test "files_test/builtins/sub_result_negative.scm" "-3"
run_success_test "files_test/builtins/mul_simple.scm" "6"
run_success_test "files_test/builtins/mul_negative.scm" "-6"
run_success_test "files_test/builtins/mul_zero.scm" "0"
run_success_test "files_test/builtins/mul_two_negatives.scm" "6"
run_success_test "files_test/builtins/div_simple.scm" "5"
run_success_test "files_test/builtins/div_truncate.scm" "3"
run_success_test "files_test/builtins/div_negative_dividend.scm" "-5"
run_success_test "files_test/builtins/div_negative_divisor.scm" "-5"
run_success_test "files_test/builtins/mod_simple.scm" "1"
run_success_test "files_test/builtins/mod_exact.scm" "0"
run_success_test "files_test/builtins/eq_equal_int.scm" "#t"
run_success_test "files_test/builtins/eq_diff_int.scm" "#f"
run_success_test "files_test/builtins/eq_bool_true.scm" "#t"
run_success_test "files_test/builtins/eq_bool_false.scm" "#t"
run_success_test "files_test/builtins/eq_diff_bool.scm" "#f"
run_success_test "files_test/builtins/eq_expressions.scm" "#t"
run_success_test "files_test/builtins/less_true.scm" "#t"
run_success_test "files_test/builtins/less_false.scm" "#f"
run_success_test "files_test/builtins/less_equal.scm" "#f"
run_success_test "files_test/builtins/less_negatives.scm" "#t"
run_success_test "files_test/builtins/less_expressions.scm" "#f"
run_success_test "files_test/builtins/nested_arithmetic.scm" "11"
run_success_test "files_test/builtins/complex_arithmetic.scm" "42"

echo ""
echo -e "${YELLOW}=== Conditional (if) Tests ===${NC}"
run_success_test "files_test/conditionals/if_true.scm" "1"
run_success_test "files_test/conditionals/if_false.scm" "2"
run_success_test "files_test/conditionals/if_with_comparison.scm" "21"
run_success_test "files_test/conditionals/if_nested.scm" "3"
run_success_test "files_test/conditionals/if_with_eq.scm" "100"
run_success_test "files_test/conditionals/if_complex_branches.scm" "30"
run_success_test "files_test/conditionals/if_with_lambda.scm" "10"
run_success_test "files_test/conditionals/if_returns_bool.scm" "#t"
run_success_test "files_test/conditionals/if_chain.scm" "2"
run_success_test "files_test/conditionals/if_deeply_nested.scm" "5"
run_success_test "files_test/conditionals/if_function_condition.scm" "10"
run_success_test "files_test/conditionals/if_arithmetic_condition.scm" "100"

echo ""
echo -e "${YELLOW}=== Complex Programs Tests ===${NC}"
run_success_test "files_test/complex/factorial.scm" "3628800"
run_success_test "files_test/complex/factorial_lambda.scm" "120"
run_success_test "files_test/complex/greater_than.scm" "#t"
run_success_test "files_test/complex/fibonacci.scm" "55"
run_success_test "files_test/complex/power.scm" "1024"
run_success_test "files_test/complex/gcd.scm" "6"
run_success_test "files_test/complex/absolute_value.scm" "42"
run_success_test "files_test/complex/max.scm" "42"
run_success_test "files_test/complex/min.scm" "17"
run_success_test "files_test/complex/sum_to_n.scm" "55"
run_success_test "files_test/complex/is_even.scm" "#t"
run_success_test "files_test/complex/is_odd.scm" "#t"
run_success_test "files_test/complex/multiple_functions.scm" "100"
run_success_test "files_test/complex/factorial_tail_recursive.scm" "3628800"
run_success_test "files_test/complex/mutual_functions.scm" "42"
run_success_test "files_test/complex/higher_order.scm" "24"
run_success_test "files_test/complex/less_or_equal.scm" "#t"
run_success_test "files_test/complex/greater_or_equal.scm" "#t"
run_success_test "files_test/complex/not_equal.scm" "#t"
run_success_test "files_test/complex/div_mod_verify.scm" "#t"
run_success_test "files_test/complex/countdown.scm" "0"

echo ""
echo -e "${YELLOW}=== Edge Cases Tests ===${NC}"
run_success_test "files_test/edge_cases/single_value.scm" "42"
run_success_test "files_test/edge_cases/long_symbol_name.scm" "42"
run_success_test "files_test/edge_cases/symbol_special_chars.scm" "42"
run_success_test "files_test/edge_cases/arithmetic_identity.scm" "0"
run_success_test "files_test/edge_cases/nested_function_calls.scm" "16"
run_success_test "files_test/edge_cases/large_computation.scm" "1000000"
run_success_test "files_test/edge_cases/zero_operations.scm" "0"
run_success_test "files_test/edge_cases/multiply_by_one.scm" "42"
run_success_test "files_test/edge_cases/subtract_same.scm" "0"
run_success_test "files_test/edge_cases/div_by_one.scm" "42"
run_success_test "files_test/edge_cases/lambda_ignore_arg.scm" "42"
run_success_test "files_test/edge_cases/recursion_depth.scm" "0"
run_success_test "files_test/edge_cases/bool_var_condition.scm" "1"
run_success_test "files_test/edge_cases/comments.scm" "42"
run_success_test "files_test/edge_cases/nested_lambda_call.scm" "15"
run_success_test "files_test/edge_cases/self_apply.scm" "42"
run_success_test "files_test/edge_cases/triple_nested_arithmetic.scm" "110"
run_success_test "files_test/edge_cases/eq_computed.scm" "#t"
run_success_test "files_test/edge_cases/deep_if_nesting.scm" "42"

echo ""
echo "========================================"
echo "           TEST RESULTS"
echo "========================================"
echo -e "Total:  $TOTAL"
echo -e "Passed: ${GREEN}$PASS${NC}"
echo -e "Failed: ${RED}$FAIL${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
