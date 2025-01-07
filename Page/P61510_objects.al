page 61510 fBM_Objects
{
    Caption = 'Objects';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "Config. Line";
#if main
    Permissions = tabledata Object = rimd;
#endif

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field("Package Code"; Rec."Package Code")
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