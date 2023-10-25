xmlport 60101 FBM_ImportSite
{
    FieldSeparator = ';';
    Format = VariableText;
    Caption = 'Import Site';
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
                trigger
    OnBeforeInsertRecord()
                begin
                    entryno += 1;
                    FBM_WSBuffer.f01 := 'SITE';
                    FBM_WSBuffer.DateTrans := Today;
                    FBM_WSBuffer.TimeTrans := Time;
                    FBM_WSBuffer.F02 := FORMAT(Today);
                    FBM_WSBuffer.F03 := FORMAT(Time);
                    FBM_WSBuffer.BatchNo := 999;
                    FBM_WSBuffer.EntryNo := entryno;
                    FBM_WSBuffer.WS := 'SITE';
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
