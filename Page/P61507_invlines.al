page 61507 FBM_invLines_FIX
{
    Caption = 'Sales Invoice Lines';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "Sales Invoice Line";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {

                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(FBM_Site; Rec.FBM_Site)
                {
                    ApplicationArea = All;
                }
                field(siteH; siteH)
                {
                    ApplicationArea = All;
                }
                field(sitedim; sitedim)
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
        invheader.get(rec."Document No.");
        siteh := invheader.FBM_Site;
        setid.setrange("Dimension Set ID", rec."Dimension Set ID");
        setid.SetRange("Dimension Code", 'HALL');
        if setid.FindFirst() then
            sitedim := setid."Dimension Value Code";

    end;

    var
        invheader: record "Sales Invoice Header";
        siteH: text[20];
        sitedim: text[20];
        setid: record "Dimension Set Entry";
}