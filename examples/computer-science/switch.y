switch_statement:
    SWITCH LPARENT expression {
        /* Save the previous value of current_switch so that it can be restored
         * at the end of this switch statement. This ensures that
         * current_switch always contains the label number of the current
         * switch statement (if inside one). This allows us to avoid problems
         * with nested switches because the inner switch will change
         * current_switch, then restore it to its previous value (i.e. that of
         * the outer switch) before we return to continue processing the outer
         * switch statement. */
        $<my_nlabel>1 = current_switch;
        current_switch = nlabel++;
    } RPARENT LCURLY case_list {
        /* Get rid of the expression being compared now that we've finished
         * processing all the cases. */
        top--;
    } DEFAULT COLON statement BREAK SEMICOLON {
        fprintf(fasm, "switch_end_%d:\n", current_switch);
        /* Restore current_switch. */
        current_switch = $<my_nlabel>1;
    } RCURLY
;

case_item:
    CASE expression COLON {
        $<my_nlabel>1 = nlabel++;
        fprintf(fasm, "\tcmpq %%%s, %%%s\n", regStk[top - 2], regStk[top - 1]);
        top--;
        fprintf(fasm, "\tjnz case_end_%d\n", $<my_nlabel>1);
    } statement BREAK SEMICOLON {
        fprintf(fasm, "\tjmp switch_end_%d\n", current_switch);
        fprintf(fasm, "case_end_%d:\n", $<my_nlabel>1);
    }
;

case_list:
    case_item
    | case_list case_item
;
