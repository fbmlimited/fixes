xmlport 60112 FBM_ImportFA
{
    FieldSeparator = ';';
    Format = VariableText;
    Caption = 'Import FA';
    Permissions = tabledata 70009 = rimd;


    schema
    {
        textelement(root)
        {
            tableelement(FBM_WSBuffer; FBM_WSBuffer)
            {

                fieldattribute(F04; FBM_WSBuffer.F04)
                {

                }
                fieldattribute(F05; FBM_WSBuffer.F05)
                {

                }
                fieldattribute(F06; FBM_WSBuffer.F06)
                {

                }
                fieldattribute(F07; FBM_WSBuffer.F07)
                {

                }
                fieldattribute(F08; FBM_WSBuffer.F08)
                {

                }
                fieldattribute(F09; FBM_WSBuffer.F09)
                {

                }
                trigger
    OnBeforeInsertRecord()
                begin
                    entryno += 1;
                    FBM_WSBuffer.f01 := 'FA';
                    FBM_WSBuffer.DateTrans := Today;
                    FBM_WSBuffer.TimeTrans := Time;
                    FBM_WSBuffer.F02 := FORMAT(Today);
                    FBM_WSBuffer.F03 := FORMAT(Time);
                    FBM_WSBuffer.BatchNo := 999;
                    FBM_WSBuffer.EntryNo := entryno;
                    FBM_WSBuffer.WS := 'FA';
                end;
            }
        }


    }

    var
        buf: record FBM_WSBuffer;
        entryno: Integer;


    trigger
           OnPreXmlPort()
    begin
        buf.FindLast();
        entryno := buf.EntryNo;
    end;
}
