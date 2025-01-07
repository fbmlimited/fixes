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
            action("acc")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.acccontr();
                    ;
                    ;

                end;

            }
            action("fixmx")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.fixmx('2430-0152', 1052.83);
                    ;
                    ;

                end;

            }
            action("fixpp")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.fixprepay();
                    Message('done');

                end;

            }
            action("poeps")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.fixpoeps();
                    Message('done');

                end;

            }
            action("Acy")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.fixacyrate();
                    Message('done');

                end;

            }
            action(CustSite)
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.csiteact();
                    Message('done');

                end;

            }

            action("InvFBM")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.fixinvfbm('2430-0715', 33140.17);
                    fix.fixinvfbm('2430-0716', 16629.97);
                    Message('done');

                end;

            }
            action("createcos")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.createcos();
                    ;
                    Message('done');

                end;

            }
            action("cleanmex")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.cleanmex2();

                end;

            }
            action("fixmex")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.fixmex();

                end;

            }
            action("setcompany")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.setcompany();

                end;

            }
            action("cleanier")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.fixier();

                end;

            }
            action("dateacqfa")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.dateacqfa();

                end;

            }
            action("cleanfamx")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.cleanFAMX();

                end;

            }
            action("INCVER")
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.incver();

                end;

            }

            action(carped)
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.CARGAPED();

                end;

            }
            action(fixppi)
            {
                ApplicationArea = all;
                trigger
                OnAction()
                var
                    fix: Codeunit FBM_Fixes;
                begin
                    fix.fixppi(true, 'PPI101045');
                    fix.fixppi(false, 'PPI101046');
                    fix.fixppi(false, 'PPI101047');
                    fix.fixppi(true, 'PPI101048');
                    fix.fixppi(false, 'PPI101049');
                    fix.fixppi(true, 'PPI101051');
                    fix.fixppi(true, 'PPI101072');
                    message('done');


                end;

            }



        }

    }
    var
        permset: code[20];
        permaction: integer;
}