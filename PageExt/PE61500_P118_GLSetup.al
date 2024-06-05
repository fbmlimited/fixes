pageextension 51500 FBM_GLsetupExt_DF extends "General Ledger Setup"
{
    layout
    {
        addbefore(General)
        {
            field(permset; permset)
            {
                ApplicationArea = all;
                TableRelation = "Aggregate Permission Set"."Role ID";
                caption = 'Permission Set';

            }
            field(permaction; permaction)
            {
                ApplicationArea = all;
                caption = 'Action (0=delete; 1=add)';


            }

        }
    }
    actions
    {
        addlast(processing)
        {
            action("DELBANK")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.delbankerr();
                    message('done');

                end;

            }
            action("setsites")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.setsite();


                end;

            }

            action("setnames")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.setnames();


                end;

            }

            action("GLE")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.delgle();


                end;

            }


            action("Permission Set")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.setpermset(permset, permaction);


                end;

            }
            action("Adjust ACY")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.fixacy2();
                    ;
                    message('done');


                end;

            }
            action("Curr2")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.fixcurr();
                    ;



                end;

            }
            action("Propagate Group")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.propgroup();




                end;

            }
            action(vendoreur)
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.fixeurvendor();
                end;

            }
            action(fixdatesTR8)
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.fixdatesdaymonth();
                end;

            }
            action("exchrate")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.fixexch();




                end;

            }
            action("exchrate day")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.fixexchday();




                end;

            }
            action("fixcos")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.fixcos();




                end;

            }
            action("exchrate1D")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.fixexch1D();




                end;

            }
            action("currvendor")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.fixcurrpurch();

                end;

            }
            action("fixcrm")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.fixcrm();

                end;

            }
            action("fixentries3")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.fixentries3();

                end;

            }
            action("fixactive")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.fixstatusfbm();


                end;

            }
            action("dataupgrade")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.dataupgrade();

                end;

            }

            action("fixline80")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.fixline();

                end;

            }
            action("fixdimtr8")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.fixdimtr8();

                end;

            }
            action("fizFAdisp")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.fixfadisp('FA00027');
                    ;

                end;

            }


        }

    }
    var
        permset: code[20];
        permaction: integer;
}