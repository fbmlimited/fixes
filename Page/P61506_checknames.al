page 61506 FBM_CheckNames_FIX
{
    Caption = 'Check Names';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = FBM_CustOpSite;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Site Code"; Rec."Site Code")
                {
                    ApplicationArea = All;
                }
                field("Site Loc Code"; Rec."Site Loc Code")
                {
                    ApplicationArea = All;
                }
                field(sitecalc; sitecalc)
                {
                    ApplicationArea = All;
                }

            }
        }
        area(Factboxes)
        {

        }
    }
    trigger
    OnAfterGetRecord()
    begin
        csite.SetRange("Customer No.", rec."Cust Loc Code");
        csite.SetRange(ActiveRec, true);
        csite.SetRange(SiteGrCode, rec."Site Code");
        sitecalc := '';
        if csite.FindFirst() then
            sitecalc := csite."Site Code";

    end;

    var
        csite: record FBM_CustomerSite_C;
        sitecalc: code[20];
}