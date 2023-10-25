page 61501 FBM_DetvendLE
{
    Caption = 'detvendle';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "Detailed Vendor Ledg. Entry";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field(FBM_approved; Rec.FBM_approved)
                {
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction();
                begin

                end;
            }
        }
    }
}