pageextension 61501 FBM_DefDimExt_FIX extends "Default Dimensions"
{
    actions
    {
        addfirst(Creation)
        {
            action("Set Mandatory")
            {
                Promoted = true;
                ApplicationArea = all;
                trigger
                OnAction()
                begin
                    fix.dimonoff(true);
                end;

            }
            action("Set Off")
            {
                Promoted = true;
                ApplicationArea = all;
                trigger
                OnAction()
                begin
                    fix.dimonoff(false);
                end;

            }

        }
    }
    var
        fix: Codeunit FBM_Fixes;
}