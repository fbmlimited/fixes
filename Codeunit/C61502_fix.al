codeunit 61501 FBM_Fixes
{
    Permissions = tabledata "Access Control" = rimd,
    tabledata "FA Depreciation Book" = rimd,
    tabledata "Sales Cr.Memo Header" = rimd,
    tabledata "Value Entry" = rimd,
    tabledata "VAT Entry" = rimd,
    tabledata "Detailed Cust. Ledg. Entry" = rimd,
    tabledata "Bank Account Ledger Entry" = rimd,
    tabledata "Purch. Inv. Line" = rimd,
    tabledata "G/L Entry" = rimd,
    tabledata "Sales Invoice Header" = rimd,
    tabledata "Sales Invoice Line" = rimd,
    tabledata "Purch. Cr. Memo Hdr." = RIMD,
    tabledata "Purch. Inv. Header" = RIMD,
    tabledata "G/L Account" = rimd,
    tabledata "Vendor Ledger Entry" = rimd,
    tabledata "Item Ledger Entry" = rimd,
    tabledata "Reservation Entry" = rimd,
    tabledata "Warehouse Entry" = rimd,
    tabledata "Purch. Cr. Memo Line" = rimd,
    tabledata "G/L Entry - VAT Entry Link" = rimd,
    tabledata "Purchase Header" = rimd,
    tabledata "Purchase Line" = rimd,
    tabledata "Purch. Rcpt. Header" = rimd,
    tabledata "Purch. Rcpt. Line" = rimd,
    tabledata "G/L Register" = rimd,
    tabledata Location = rimd,
    tabledata bin = rimd,
    tabledata "Bin Content" = rimd,
    tabledata "Detailed Vendor Ledg. Entry" = rimd,
    tabledata "Invt. Receipt Header" = rimd,
    tabledata "Invt. Receipt Line" = rimd,
    tabledata "Invt. Shipment Header" = rimd,
    tabledata "Invt. Shipment Line" = rimd,
    tabledata "G/L - Item Ledger Relation" = rimd,
    tabledata "Item Application Entry" = rimd,
    tabledata "Integration Synch. Job" = rimd,
    tabledata "Integration Synch. Job Errors" = rimd,
    tabledata "Avg. Cost Adjmt. Entry Point" = rimd,
    tabledata "Job Queue Log Entry" = rimd,
    tabledata "Warehouse Employee" = rimd,
    tabledata "Direct Trans. Header" = rimd,
    tabledata "Direct Trans. Line" = rimd,
    tabledata "FA Ledger Entry" = rimd;

    var
        Tempexcelbuffer: record "Excel Buffer" temporary;
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";

        SheetName, ErrorMessage : Text;
        FileInStream: InStream;
        ImportFileLbl: Label 'Import file';
        fa: record "Fixed Asset";
        rn: Integer;

    procedure fixqty()

    var
        pinvline: record "Purch. Inv. Line";
    begin
        pinvline.SetRange("Document No.", 'P-APV003105');
        pinvline.SetRange("Line No.", 610000);
        if pinvline.FindFirst() then begin
            pinvline.Validate(Quantity, 1);
            pinvline.Modify();
        end;


    end;

    procedure dimonoff(seton: Boolean)
    var
        defdim: record "Default Dimension";
        comp: record Company;
    begin
        // comp.FindFirst();
        // repeat
        // defdim.ChangeCompany(comp.Name);
        defdim.SetRange("Table ID", 15);

        if defdim.FindFirst() then
            repeat

                if defdim."Value Posting" = defdim."Value Posting"::"Code Mandatory" then begin
                    defdim.FBM_Marked := true;
                    defdim.Modify();
                end;
                if seton then begin
                    if defdim.FBM_Marked then
                        defdim."Value Posting" := defdim."Value Posting"::"Code Mandatory";

                end
                else
                    if defdim.FBM_Marked then
                        defdim."Value Posting" := defdim."Value Posting"::" ";
                defdim.Modify()
            until defdim.Next() = 0;
        // until comp.Next() = 0;

    end;

    procedure setsite()
    var
        sinv: record "Sales Invoice Header";
        cle: record "Cust. Ledger Entry";
        comp: record Company;
        scrm: record "Sales Cr.Memo Header";
        glsetup: record "General Ledger Setup";
        dimhall: integer;
    begin


        comp.FindFirst();
        repeat
            cle.ChangeCompany(comp.Name);
            sinv.ChangeCompany(comp.Name);
            scrm.ChangeCompany(comp.Name);
            glsetup.ChangeCompany(comp.Name);
            glsetup.get;
            dimhall := 0;
            if glsetup."Shortcut Dimension 3 Code" = 'HALL' then dimhall := 3;
            if glsetup."Shortcut Dimension 4 Code" = 'HALL' then dimhall := 4;
            if glsetup."Shortcut Dimension 5 Code" = 'HALL' then dimhall := 5;
            if glsetup."Shortcut Dimension 6 Code" = 'HALL' then dimhall := 6;
            if glsetup."Shortcut Dimension 7 Code" = 'HALL' then dimhall := 7;
            if glsetup."Shortcut Dimension 8 Code" = 'HALL' then dimhall := 8;
            if comp.Name = 'NTT Ltd Branch' then begin // 4 SPECIFIC CASES, HARDCODED
                cle.SetRange("Document No.", 'CR2023/22284');
                if cle.FindFirst() then
                    repeat
                        cle.FBM_Site := 'PH03AS03-0008';
                        cle.Modify();
                    until cle.Next() = 0;

                cle.SetRange("Document No.", 'CR2023/22803');
                if cle.FindFirst() then
                    repeat
                        cle.FBM_Site := 'PH0TYG02-0001';
                        cle.Modify();
                    until cle.Next() = 0;
                cle.SetRange("Document No.", 'CR2024/25190');
                if cle.FindFirst() then
                    repeat
                        cle.FBM_Site := 'PH0PTG01-0002';
                        cle.Modify();
                    until cle.Next() = 0;
                cle.SetRange("Document No.", 'CR2024/25553');
                if cle.FindFirst() then
                    repeat
                        cle.FBM_Site := 'PH0ECP03-0010';
                        cle.Modify();
                    until cle.Next() = 0;
                cle.Reset();
            end;
            if cle.FindFirst() then
                repeat
                    if sinv.get(cle."Document No.") then begin //INVOICE
                        if (sinv.FBM_Site <> '') and (cle.FBM_Site = '') then begin

                            cle.FBM_Site := sinv.FBM_Site;
                            cle.Modify();
                        end;
                    end
                    else

                        if scrm.get(cle."Document No.") then begin // CREDIT MEMO
                            if (scrm.FBM_Site <> '') and (cle.FBM_Site = '') then begin

                                cle.FBM_Site := scrm.FBM_Site;
                                cle.Modify();
                            end;
                        end
                        ELSE begin
                            if cle."Source Code" = 'CASHRECJNL' THEN BEGIN// reading the sit from HALL dimension
                                case dimhall of
                                    3:
                                        BEGIN
                                            CLE.CalcFields("Shortcut Dimension 3 Code");
                                            if (cle.FBM_Site = '') and (cle."Shortcut Dimension 3 Code" <> '') then
                                                cle.FBM_Site := cle."Shortcut Dimension 3 Code";
                                        END;
                                    4:
                                        BEGIN
                                            CLE.CalcFields("Shortcut Dimension 4 Code");
                                            if (cle.FBM_Site = '') and (cle."Shortcut Dimension 4 Code" <> '') then
                                                cle.FBM_Site := cle."Shortcut Dimension 4 Code";
                                        END;
                                    5:
                                        BEGIN
                                            CLE.CalcFields("Shortcut Dimension 5 Code");
                                            if (cle.FBM_Site = '') and (cle."Shortcut Dimension 5 Code" <> '') then
                                                cle.FBM_Site := cle."Shortcut Dimension 5 Code";
                                        END;
                                    6:
                                        BEGIN
                                            CLE.CalcFields("Shortcut Dimension 6 Code");
                                            if (cle.FBM_Site = '') and (cle."Shortcut Dimension 6 Code" <> '') then
                                                cle.FBM_Site := cle."Shortcut Dimension 6 Code";
                                        END;
                                    7:
                                        BEGIN
                                            CLE.CalcFields("Shortcut Dimension 7 Code");
                                            if (cle.FBM_Site = '') and (cle."Shortcut Dimension 7 Code" <> '') then
                                                cle.FBM_Site := cle."Shortcut Dimension 7 Code";
                                        END;
                                    8:
                                        BEGIN
                                            CLE.CalcFields("Shortcut Dimension 8 Code");
                                            if (cle.FBM_Site = '') and (cle."Shortcut Dimension 8 Code" <> '') then
                                                cle.FBM_Site := cle."Shortcut Dimension 8 Code";
                                        END
                                end;
                                cle.Modify();
                            END;
                        end;
                until cle.Next() = 0;

        until comp.Next() = 0;
        message('done');
    end;

    procedure setnames()
    var
        customer: record Customer;
        custle: record "Cust. Ledger Entry";
        vendor: record Vendor;
        vendle: record "Vendor Ledger Entry";
        comp: record Company;
    begin
        comp.FindFirst();
        repeat
            customer.ChangeCompany(comp.Name);
            custle.ChangeCompany(comp.Name);
            vendor.ChangeCompany(comp.Name);
            vendle.ChangeCompany(comp.Name);
            if custle.FindFirst() then
                repeat
                    if customer.get(custle."Customer No.") then
                        if custle."Customer Name" = '' then begin
                            custle."Customer Name" := customer.Name;
                            custle.Modify();
                        end;
                until custle.Next() = 0;
            if vendle.FindFirst() then
                repeat
                    if vendor.get(vendle."Vendor No.") then
                        if vendle."Vendor Name" = '' then begin
                            vendle."Vendor Name" := vendor.Name;
                            vendle.Modify();
                        end;
                until vendle.Next() = 0;

        until comp.Next() = 0;
        message('done');
    end;

    procedure delgle()
    var
        glentry: record "G/L Entry";
    begin
        glentry.SetRange("Entry No.", 463078);
        glentry.DeleteAll();
        message('Done');
    end;


    procedure fixpo()
    var
        pline: record "Purchase Line";
    begin
        pline.SetRange("Document Type", pline."Document Type"::Order);
        pline.SetRange("Document No.", '005148');
        pline.SetRange("Line No.", 10000);
        if pline.FindFirst() then begin
            pline."Prepayment Amount" := 0;
            pline."Prepmt. Amt. Incl. VAT" := 0;
            pline."Prepmt. Amount Inv. Incl. VAT" := 859485.86;
            pline."Prepmt. Line Amount" := 859485.87;
            pline."Prepmt. VAT Base Amt." := 0;
            pline."Prepmt. Amt. Inv." := 859485.86;
            pline.Modify();
        end;

    end;


    procedure delbankerr()
    var
        bankle: record "Bank Account Ledger Entry";
    begin
        bankle.setrange("Bank Account No.", 'ERROR');
        BANKLE.ModifyAll("Bank Account No.", 'PETTY CASH EUR - DRA');
    end;


    procedure fixvat()
    var
        csite: record FBM_CustomerSite_C;
        comp: record Company;
        site: Record FBM_Site;
    begin
        comp.FindFirst();
        repeat
            csite.ChangeCompany(comp.name);
            if csite.FindFirst() then
                repeat
                    site.Reset();
                    site.SetRange("Site Code", csite.SiteGrCode);
                    if site.FindFirst() then
                        if csite."Vat Number" = '' then begin
                            csite."Vat Number" := site."Vat Number";
                            csite.Modify();
                        end;
                until csite.next = 0;
        until comp.next = 0;
        message('done');

    end;


    procedure fixacy()
    var
        glentry: record "G/L Entry";
        exchrate: record "Currency Exchange Rate";
        crec: integer;
    begin
        exchrate.ChangeCompany('FBM Ltd');
        glentry.SetFilter("Posting Date", '>=%1 & <=%2', DMY2Date(19, 04, 2023), DMY2Date(20, 04, 2023));
        if glentry.FindFirst() then
            repeat
                if glentry."Additional-Currency Amount" = glentry.Amount then begin
                    if abs(glentry.Amount) > 1 then begin
                        crec += 1;
                        exchrate.get('PHP', glentry."Posting Date");
                        glentry.validate("Additional-Currency Amount", glentry.Amount / exchrate."Exchange Rate Amount");
                        glentry.Modify();
                    end;
                end;
            until glentry.Next() = 0;
        message(format(crec));
    end;

    procedure fixacyrate()
    var
        glentry: record "G/L Entry";
        exchrate: record "Currency Exchange Rate";
        crec: integer;
    begin
        //exchrate.ChangeCompany('NTT Ltd Branch');
        glentry.SetFilter("Posting Date", '>=%1 & <=%2', DMY2Date(01, 09, 2024), DMY2Date(30, 09, 2024));
        //GLENTRY.SetFilter("G/L Account No.", '<>%1 & <>%2 ', '668400', '768400');
        if glentry.FindFirst() then
            repeat
                // if glentry.amount <> 0 then
                // if ((glentry."Additional-Currency Amount" / glentry.Amount) > 0.98) and
                //  ((glentry."Additional-Currency Amount" / glentry.Amount) < 1.02) then begin
                //if abs(glentry.Amount) > 1 then begin
                crec += 1;
                exchrate.get('USD', glentry."Posting Date");
                glentry.validate("Additional-Currency Amount", glentry.Amount / exchrate."Relational Exch. Rate Amount");
                glentry.Modify();
            //end;
            // end;
            until glentry.Next() = 0;
        message(format(crec));
    end;

    procedure fixacyrateC()
    var
        glentry: record "G/L Entry";
        exchrate: record "Currency Exchange Rate";
        crec: integer;
    begin
        //exchrate.ChangeCompany('NTT Ltd Branch');
        glentry.SetFilter("Posting Date", '>=%1 & <=%2', DMY2Date(24, 08, 2024), DMY2Date(31, 08, 2024));
        //GLENTRY.SetFilter("G/L Account No.", '<>%1 & <>%2 ', '668400', '768400');
        if glentry.FindFirst() then
            repeat
                // if glentry.amount <> 0 then
                // if ((glentry."Additional-Currency Amount" / glentry.Amount) > 0.98) and
                //  ((glentry."Additional-Currency Amount" / glentry.Amount) < 1.02) then begin
                //if abs(glentry.Amount) > 1 then begin
                crec += 1;
                exchrate.get('USD', glentry."Posting Date");
                glentry.validate("Additional-Currency Amount", glentry.Amount * exchrate."Exchange Rate Amount");
                glentry.Modify();
            //end;
            // end;
            until glentry.Next() = 0;
        message(format(crec));
    end;


    procedure fixacy2()
    var
        glentry: record "G/L Entry";
        exchrate: record "Currency Exchange Rate";
        crec: integer;
    begin
        exchrate.ChangeCompany('D2R Ltd Branch');
        glentry.SetFilter("Posting Date", '>=%1 & <=%2', DMY2Date(20, 12, 2023), DMY2Date(31, 12, 2023));
        if glentry.FindFirst() then
            repeat
                if (glentry."Additional-Currency Amount" = glentry.Amount) or (glentry."Additional-Currency Amount" = 0) then begin
                    if abs(glentry.Amount) > 1 then begin
                        crec += 1;
                        if exchrate.get('USD', glentry."Posting Date") then
                            glentry.validate("Additional-Currency Amount", glentry.Amount / exchrate."Relational Exch. Rate Amount")
                        else begin
                            exchrate.get('USD', calcdate('-1D', glentry."Posting Date"));
                            glentry.validate("Additional-Currency Amount", glentry.Amount / exchrate."Relational Exch. Rate Amount")
                        end;
                        glentry.Modify();
                    end;
                end;
            until glentry.Next() = 0;
        message(format(crec));
    end;

    procedure fixacy3()
    var
        glentry: record "G/L Entry";
        exchrate: record "Currency Exchange Rate";
        crec: integer;
    begin
        exchrate.ChangeCompany('NTT Ltd Branch');
        glentry.SetFilter("Posting Date", '>=%1 & <=%2', DMY2Date(01, 08, 2023), DMY2Date(31, 08, 2023));
        if glentry.FindFirst() then
            repeat
                if ((glentry."Additional-Currency Amount" < 0) and (glentry.Amount > 0)) or ((glentry."Additional-Currency Amount" > 0) and (glentry.Amount < 0)) then begin
                    //if abs(glentry.Amount) > 1 then begin
                    crec += 1;

                    glentry.validate("Additional-Currency Amount", -glentry."Additional-Currency Amount");

                    glentry.Modify();
                    // end;
                end;
            until glentry.Next() = 0;
        message(format(crec));
    end;

    procedure fixdimfmq()
    var
        glentry: record "G/L Entry";
        glentry2: record "G/L Entry";
        dimmgt: Codeunit DimensionManagement;
        dse: record "Dimension Set Entry" temporary;
        nsi: Integer;
    begin
        glentry.Setfilter("Dimension Set ID", '%1|%2', 1838, 57);

        if glentry.FindFirst() then
            repeat



                dse.init();
                if glentry."Global Dimension 1 Code" <> '' then begin
                    dse."Dimension Set ID" := -1;
                    dse.validate("Dimension Code", 'BUDGET_ACCOUNT');
                    dse.validate("Dimension Value Code", glentry."Global Dimension 1 Code");
                    dse.Insert(true);
                end;


                if glentry."Global Dimension 2 Code" <> '' then begin
                    dse."Dimension Set ID" := -1;
                    dse.validate("Dimension Code", 'BUDGET_GROUP');
                    dse.validate("Dimension Value Code", glentry."Global Dimension 2 Code");
                    dse.Insert(true);
                end;


                glentry.CalcFields("Shortcut Dimension 3 Code");
                if glentry."Shortcut Dimension 3 Code" <> '' then begin
                    dse."Dimension Set ID" := -1;
                    dse.validate("Dimension Code", 'CENTRO CUSTO');

                    dse.validate("Dimension Value Code", glentry."Shortcut Dimension 3 Code");
                    dse.Insert(true);
                end;


                nsi := dimmgt.GetDimensionSetID(dse);
                if nsi <> 0 then begin
                    glentry2.get(glentry."Entry No.");
                    glentry2.validate("Dimension Set ID", nsi);
                    glentry2.Modify();
                end;
                dse.DeleteAll();
            until glentry.Next() = 0;
    end;

    procedure fixcurr()
    var
        sinv: record "Sales Invoice Header";
        cexch: record "Currency Exchange Rate";
    begin
        sinv.SetRange("Currency Code", 'PHP');
        if sinv.FindFirst() then
            repeat
                sinv.FBM_Currency2 := 'USD';
                cexch.get('PHP', sinv."Posting Date");
                sinv.CalcFields(Amount);
                sinv.FBM_LocalCurrAmt := sinv.Amount / sinv."Currency Factor";
                sinv.Modify();
            until sinv.Next() = 0;
        message('done');
    end;

    procedure fixexch()
    var
        cexch: record "Currency Exchange Rate";
        cexch2: record "Currency Exchange Rate";
        comp: record Company;
        cinfo: record "company Information";
    begin
        comp.findfirst;
        repeat

            cinfo.changecompany(comp.name);
            cinfo.get();
            cexch.changecompany(comp.name);
            cexch2.changecompany(comp.name);
            cexch.SetRange("Starting Date", DMY2Date(Date2DMY(calcdate('-1D', Today), 1), Date2DMY(calcdate('-1D', Today), 2), Date2DMY(calcdate('-1D', Today), 3)));
            cexch2.SetRange("Starting Date", Today);

            if cexch.FindFirst() then
                repeat
                    cexch2.SetRange("Currency Code", cexch."Currency Code");
                    if not cexch2.FindFirst() then begin
                        cexch2.init;
                        cexch2."Starting Date" := Today;
                        cexch2."Currency Code" := cexch."Currency Code";
                        cexch2."Exchange Rate Amount" := cexch."Exchange Rate Amount";
                        cexch2."Adjustment Exch. Rate Amount" := cexch."Adjustment Exch. Rate Amount";
                        cexch2."Relational Currency Code" := cexch."Relational Currency Code";
                        cexch2."Relational Exch. Rate Amount" := cexch."Relational Exch. Rate Amount";
                        cexch2."Relational Adjmt Exch Rate Amt" := cexch."Relational Adjmt Exch Rate Amt";
                        cexch2."Fix Exchange Rate Amount" := cexch."Fix Exchange Rate Amount";
                        cexch2.Insert();
                    end;

                until cexch.Next() = 0;
            // message('Done 16/3');
            // cexch.Reset();
            // cexch2.Reset();
            // cexch.SetRange("Starting Date", DMY2Date(15, 03, 2024));
            // cexch2.SetRange("Starting Date", DMY2Date(17, 03, 2024));

            // if cexch.FindFirst() then
            //     repeat
            //         cexch2.SetRange("Currency Code", cexch."Currency Code");
            //         if not cexch2.FindFirst() then begin
            //             cexch2.init;
            //             cexch2."Starting Date" := DMY2Date(17, 03, 2024);
            //             cexch2."Currency Code" := cexch."Currency Code";
            //             cexch2."Exchange Rate Amount" := cexch."Exchange Rate Amount";
            //             cexch2."Adjustment Exch. Rate Amount" := cexch."Adjustment Exch. Rate Amount";
            //             cexch2."Relational Currency Code" := cexch."Relational Currency Code";
            //             cexch2."Relational Exch. Rate Amount" := cexch."Relational Exch. Rate Amount";
            //             cexch2."Relational Adjmt Exch Rate Amt" := cexch."Relational Adjmt Exch Rate Amt";
            //             cexch2."Fix Exchange Rate Amount" := cexch."Fix Exchange Rate Amount";
            //             cexch2.Insert();
            //         end;

            //     until cexch.Next() = 0;
            // message('Done 9/3');
            // cexch.Reset();
            // cexch2.Reset();
            // cexch.SetRange("Starting Date", DMY2Date(07, 03, 2024));
            // cexch2.SetRange("Starting Date", DMY2Date(10, 03, 2024));

            // if cexch.FindFirst() then
            //     repeat
            //         cexch2.SetRange("Currency Code", cexch."Currency Code");
            //         if not cexch2.FindFirst() then begin
            //             cexch2.init;
            //             cexch2."Starting Date" := DMY2Date(10, 03, 2024);
            //             cexch2."Currency Code" := cexch."Currency Code";
            //             cexch2."Exchange Rate Amount" := cexch."Exchange Rate Amount";
            //             cexch2."Adjustment Exch. Rate Amount" := cexch."Adjustment Exch. Rate Amount";
            //             cexch2."Relational Currency Code" := cexch."Relational Currency Code";
            //             cexch2."Relational Exch. Rate Amount" := cexch."Relational Exch. Rate Amount";
            //             cexch2."Relational Adjmt Exch Rate Amt" := cexch."Relational Adjmt Exch Rate Amt";
            //             cexch2."Fix Exchange Rate Amount" := cexch."Fix Exchange Rate Amount";
            //             cexch2.Insert();
            //         end;


            //     until cexch.Next() = 0;
            message('Done ' + cinfo."Custom System Indicator Text")
        until comp.next = 0;

        // cexch.Reset();
        // cexch2.Reset();
        // cexch.SetRange("Starting Date", DMY2Date(05, 03, 2024));
        // cexch2.SetRange("Starting Date", DMY2Date(07, 03, 2024));
        // if cexch.FindFirst() then
        //     repeat
        //         cexch2.SetRange("Currency Code", cexch."Currency Code");
        //         if not cexch2.FindFirst() then begin
        //             cexch2.init;
        //             cexch2."Starting Date" := DMY2Date(07, 03, 2024);
        //             cexch2."Currency Code" := cexch."Currency Code";
        //             cexch2."Exchange Rate Amount" := cexch."Exchange Rate Amount";
        //             cexch2."Adjustment Exch. Rate Amount" := cexch."Adjustment Exch. Rate Amount";
        //             cexch2."Relational Currency Code" := cexch."Relational Currency Code";
        //             cexch2."Relational Exch. Rate Amount" := cexch."Relational Exch. Rate Amount";
        //             cexch2."Relational Adjmt Exch Rate Amt" := cexch."Relational Adjmt Exch Rate Amt";
        //             cexch2."Fix Exchange Rate Amount" := cexch."Fix Exchange Rate Amount";
        //             cexch2.Insert();
        //         end;

        //     until cexch.Next() = 0;


        // message('Done');
    end;

    procedure fixcurrpurch()
    var
        purchinv: record "Purch. Inv. Header";
        purccrm: record "Purch. Cr. Memo Hdr.";
        purchhead: record "Purchase Header";
        vendor: record Vendor;
        stori: Enum "Purchase Document Status";
    begin
        purchinv.SetRange("Currency Code", 'EUR');
        if purchinv.FindFirst() then
            repeat
                purchinv."Currency Code" := '';
                purchinv.Modify()
            UNTIL PURCHINV.Next() = 0;
        purccrm.SetRange("Currency Code", 'EUR');
        if purccrm.FindFirst() then
            repeat
                purccrm."Currency Code" := '';
                purccrm.Modify()
            UNTIL purccrm.Next() = 0;
        purchhead.SetRange("Currency Code", 'EUR');
        if purchhead.FindFirst() then
            repeat
                stori := purchhead.Status;
                if purchhead.status <> purchhead.Status::Open then
                    purchhead.Status := purchhead.Status::Open;
                purchhead."Currency Code" := '';
                purchhead.Status := stori;
                purchhead.Modify()
            UNTIL purchhead.Next() = 0;
        vendor.SetRange("Currency Code", 'EUR');
        if vendor.FindFirst() then
            repeat
                vendor.Validate("Currency Code", '');
                vendor.Modify()
            UNTIL vendor.Next() = 0;
        MESSAGE('DONE');


    end;

    procedure checkacy()
    var
        glentry: record "G/L Entry";
    begin
        glentry.setrange("Posting Date", DMY2Date(1, 8, 2023), DMY2Date(30, 09, 2023));
        if glentry.FindFirst() then
            repeat
                if glentry."Additional-Currency Amount" <> 0 then
                    if ((glentry.Amount / glentry."Additional-Currency Amount") < 52) or ((glentry.Amount / glentry."Additional-Currency Amount") > 58) then
                        glentry.Mark(true);
            until glentry.Next() = 0;
        glentry.MarkedOnly(true);
        page.RunModal(20, glentry);

    end;

    procedure fixacystrange()
    var
        glentry: record "G/L Entry";
        exchrate: record "Currency Exchange Rate";
        pdate: date;
    begin
        glentry.setrange("Posting Date", DMY2Date(1, 8, 2023), DMY2Date(30, 09, 2023));
        if glentry.FindFirst() then
            repeat
                pdate := glentry."Posting Date";
                if (((glentry."Additional-Currency Amount" <> 0) and (glentry.Amount = 0))) or
                (((glentry."Additional-Currency Amount" < 0) and (glentry.Amount > 0)) or ((glentry."Additional-Currency Amount" > 0) and (glentry.Amount < 0))) then begin
                    if exchrate.get('USD', glentry."Posting Date") then
                        glentry.validate("Additional-Currency Amount", glentry.Amount / exchrate."Relational Exch. Rate Amount")
                    else begin
                        while not
                       exchrate.get('USD', pdate) do begin
                            pdate := calcdate('-1D', pdate)
                        end;
                        glentry.validate("Additional-Currency Amount", glentry.Amount / exchrate."Relational Exch. Rate Amount");
                    end;
                    glentry.Modify();
                end;
                pdate := glentry."Posting Date";
                if (glentry."Additional-Currency Amount" <> 0) then
                    if (round(glentry.amount / glentry."Additional-Currency Amount", 0.01) = 0.00) or
                                    ((glentry."Additional-Currency Amount" <> 0) and ((((glentry.Amount / glentry."Additional-Currency Amount") < 52) or ((glentry.Amount / glentry."Additional-Currency Amount") > 58)))) then begin

                        if exchrate.get('USD', glentry."Posting Date") then
                            glentry.validate("Additional-Currency Amount", glentry.Amount / exchrate."Relational Exch. Rate Amount")
                        else begin
                            while not
                           exchrate.get('USD', pdate) do begin
                                pdate := calcdate('-1D', pdate)
                            end;
                            glentry.validate("Additional-Currency Amount", glentry.Amount / exchrate."Relational Exch. Rate Amount");
                        end;
                        glentry.Modify();
                    end;
            until glentry.Next() = 0;


    end;

    procedure fixcrm()
    var
        ph: record "Purchase Header";
    begin
        ph.SetRange("Document Type", ph."Document Type"::Order);
        ph.SetRange("No.", 'INTL-NTT2022-0115');
        if ph.FindFirst() then begin
            ph."Prepmt. Cr. Memo No." := '';
            ph.Modify();
            message('Done');

        end;

    end;


    procedure fixic()
    var
        paric: record "IC Partner";
    begin
        paric.SetRange(code, 'IC0012');
        IF PARIC.FindFirst() THEN BEGIN
            PARIC."Vendor No." := 'VIC112';
            paric.Modify();
        END;
    end;


    procedure fixitem()
    var
        item: record item;
    begin
        if item.get('598522') then begin
            item."Unit Cost" := 960;
            item.Modify()
        end;
    end;

    procedure deletelog()
    var
        changelog: record "Change Log Entry";
    begin
        changelog.DeleteAll();
        message('Done');
    end;

    procedure setpermset(permset: code[20]; action: Integer)
    var
        acccont: record "Access Control";
        user: record user;
    begin
        user.SetRange(State, user.state::Enabled);
        if user.FindFirst() then
            repeat
                acccont.SetRange("User Name", user."User Name");
                acccont.SetRange("Role ID", permset);
                if action = 0 then begin
                    if acccont.FindFirst() then
                        acccont.Delete();

                end
                else
                    if acccont.IsEmpty then begin
                        acccont.Init();
                        acccont.validate("User Security ID", user."User Security ID");
                        acccont.validate("Role ID", permset);
                        acccont.Validate(Scope, acccont.Scope::System);
                        acccont.Insert(true);
                    end;

            until user.next = 0;
        message('Done');
    end;

    procedure propgroup()
    var
        cust: record customer;
        fbmcust: record FBM_Customer;
        comp: record Company;
    begin
        comp.FindFirst();
        repeat
            cust.ChangeCompany(comp.Name);
            if cust.FindFirst() then
                repeat
                    fbmcust.setrange("No.", cust.FBM_GrCode);
                    if fbmcust.FindFirst() then begin
                        fbmcust.FBM_Group := cust.FBM_Group;
                        fbmcust.FBM_SubGroup := cust.FBM_SubGroup;
                        fbmcust.Modify();
                    end;
                until cust.next = 0;
        until comp.next = 0;

    end;

    procedure fixeurvendor()
    var
        vle: record "Vendor Ledger Entry";
        vendor: record Vendor;
        PI: record "Purchase Header";
        exchrate: record "Currency Exchange Rate";
        CF: Decimal;
    begin
        IF VLE.FindFirst() then
            repeat
                if vle."Currency Code" = 'EUR' then BEGIN
                    exchrate.SetRange("Starting Date", vle."Posting Date");
                    exchrate.SetRange("Currency Code", 'EUR');
                    IF exchrate.FindFirst() THEN
                        cf := exchrate."Exchange Rate Amount"
                    else
                        while cf = 0 do begin
                            exchrate.SetRange("Starting Date", calcdate('-1D', vle."Posting Date"));
                            exchrate.SetRange("Currency Code", 'EUR');
                            cf := exchrate."Exchange Rate Amount"
                        end;

                    vle."Original Currency Factor" := cf;
                    VLE."Adjusted Currency Factor" := cf;
                    VLE.Modify();
                END;
            Until vle.next = 0;
        message('vle');
        if vendor.FindFirst() then
            repeat
                if vendor."Currency Code" = '' then begin
                    vendor."Currency Code" := 'EUR';
                    VENDOR.Modify();
                end;
            UNTIL vendor.NEXT = 0;
        message('vendor');
        if pi.FindFirst() then
            repeat
                if pi."Currency Code" = '' then begin
                    pi."Currency Code" := 'EUR';
                    pi.Modify();

                end;
            until pi.Next() = 0;
        message('Done');

    end;

    procedure fixdatesdaymonth()
    var
        glentry: record "G/L Entry";
        oldday: integer;
        oldmonth: integer;
        newday: Integer;
        newmonth: Integer;
        vtime1: time;
        vtime2: time;
    begin
        evaluate(vtime1, '09:28:00');
        evaluate(vtime2, '11:18:01');
        glentry.SetRange(SystemCreatedAt, system.CreateDateTime(DMY2Date(5, 12, 2023), vtime1), system.CreateDateTime(DMY2Date(12, 12, 2023), vtime2));
        glentry.SetRange("Source Code", 'CASHRECJNL');
        glentry.Findfirst();
        repeat
            oldday := Date2DMY(glentry."Posting Date", 1);
            oldmonth := Date2DMY(glentry."Posting Date", 2);
            newday := oldmonth;
            newmonth := oldday;
            glentry.Validate("Posting Date", DMY2Date(newday, newmonth, 2023));
            glentry.modify;
        until glentry.next = 0;

    end;

    procedure fixentries()
    var
        exchrate: record "Currency Exchange Rate";
        custle: record "Cust. Ledger Entry";
        detcustle: record "Detailed Cust. Ledg. Entry";
        bankle: record "Bank Account Ledger Entry";
        gle: record "G/L Entry";
        cc: Integer;
        VATE: RECORD "VAT Entry";
        value: record "Value Entry";
    begin
        custle.SetRange("Posting Date", DMY2Date(12, 03, 2024));
        custle.SetRange("Currency Code", 'USD');
        if custle.FindFirst() then
            repeat
                CUSTLE.CalcFields("Amount (LCY)", Amount);
                if custle.Amount <> custle."Amount (LCY)" then begin
                    cc += 1;
                    custle.VALIDATE("Sales (LCY)", custle.Amount);
                    custle.Modify();
                    gle.SetRange("Document No.", custle."Document No.");
                    if gle.FindFirst() then
                        repeat
                            gle.Validate(Amount, gle.amount / 55.889);
                            exchrate.get('EUR', gle."Posting Date");
                            gle.validate("Additional-Currency Amount", gle.Amount * exchrate."Exchange Rate Amount");
                            gle.Modify();
                        until gle.Next() = 0;
                    VATE.SetRange("Document No.", custle."Document No.");
                    if VATE.FindFirst() then
                        repeat
                            VATE.Validate(BASE, VATE.BASE / 55.889);
                            VATE.Modify();
                        until VATE.Next() = 0;
                    value.SetRange("Document No.", custle."Document No.");
                    if value.FindFirst() then
                        repeat
                            value.Validate("Sales Amount (Actual)", value."Sales Amount (Actual)" / 55.889);
                            value.Modify();
                        until value.Next() = 0;
                end;
            until custle.Next() = 0;
        Message(format(cc));
        cc := 0;
        detcustle.SetRange("Posting Date", DMY2Date(12, 03, 2024));
        detcustle.SetRange("Currency Code", 'USD');
        if detcustle.FindFirst() then
            repeat

                if detcustle.Amount <> detcustle."Amount (LCY)" then begin
                    cc += 1;
                    detcustle.VALIDATE("Amount (LCY)", detcustle.Amount);
                    detcustle.Modify();
                end;
            until detcustle.Next() = 0;
        Message(format(cc));
        cc := 0;
        bankle.SetRange("Posting Date", DMY2Date(11, 03, 2024));
        bankle.SetRange("Currency Code", 'USD');
        if bankle.FindFirst() then
            repeat

                if bankle.Amount <> bankle."Amount (LCY)" then begin
                    cc += 1;
                    bankle.validate("Amount (LCY)", bankle.Amount);


                    bankle.Modify();
                end;
            until bankle.Next() = 0;
        Message(format(cc));
    end;

    procedure fixentries2()
    var

        cc: Integer;
        bankle: record "Bank Account Ledger Entry";
        gle: record "G/L Entry";
        exchrate: record "Currency Exchange Rate";
        amt: decimal;
    begin
        cc := 0;
        bankle.SetRange("Posting Date", DMY2Date(11, 03, 2024));
        bankle.SetRange("Currency Code", 'USD');
        if bankle.FindFirst() then
            repeat

                //if bankle.Amount <> bankle."Amount (LCY)" then begin
                cc += 1;
                bankle.validate("Amount (LCY)", bankle.Amount);
                gle.SetRange("Document No.", bankle."Document No.");
                gle.SetRange("Source Code", bankle."Source Code");
                gle.SetRange("Posting Date", DMY2Date(11, 03, 2024));
                if gle.FindFirst() then
                    repeat
                        amt := gle.Amount;
                        gle.validate(Amount, amt / 55.889);

                        exchrate.get('EUR', gle."Posting Date");
                        gle."Additional-Currency Amount" := (amt / 55.889) * exchrate."Exchange Rate Amount";
                        gle.UpdateDebitCredit(false);
                        gle.Modify();
                    until gle.Next() = 0;


                bankle.Modify();
            //end;
            until bankle.Next() = 0;
        Message(format(cc));
    end;

    procedure fixentries3()
    var

        cc: Integer;
        sinv: record "Sales Invoice Header";
        scrm: record "Sales Cr.Memo Header";

        exchrate: record "Currency Exchange Rate";
        amt: decimal;
    begin
        cc := 0;
        sinv.SetRange("Posting Date", DMY2Date(12, 03, 2024));
        sinv.SetRange("Currency Code", 'USD');
        if sinv.FindFirst() then
            repeat

                //if bankle.Amount <> bankle."Amount (LCY)" then begin
                cc += 1;

                sinv."Currency Factor" := 1;


                sinv.Modify();
            until sinv.Next() = 0;
        Message(format(cc));
        cc := 0;
        scrm.SetRange("Posting Date", DMY2Date(12, 03, 2024));
        scrm.SetRange("Currency Code", 'USD');
        if scrm.FindFirst() then
            repeat

                //if bankle.Amount <> bankle."Amount (LCY)" then begin
                cc += 1;

                scrm."Currency Factor" := 1;


                scrm.Modify();
            until scrm.Next() = 0;
        Message(format(cc));





        Message(format(cc));
    end;

    procedure fixactive()
    var
        cos: record FBM_CustOpSite;
        csite: Record FBM_CustomerSite_C;
        comp: record Company;
        cinfo: record "Company Information";
        subs: text[20];
        country: record "Country/Region";

    begin
        comp.FindFirst();
        repeat
            cinfo.ChangeCompany(comp.Name);
            cinfo.get();
            country.ChangeCompany(comp.Name);
            if cinfo.FBM_EnSiteWS then begin
                csite.ChangeCompany(comp.Name);
                csite.FindFirst();
                repeat

                    cos.Reset();
                    subs := '';
                    csite.CalcFields("Country/Region Code_FF");
                    if country.get(csite."Country/Region Code_FF") then
                        subs := cinfo."Custom System Indicator Text" + ' ' + country.FBM_Country3;
                    cos.SetRange(Subsidiary, subs);
                    cos.SetRange("Site Loc Code", csite."Site Code");

                    if cos.FindFirst() then begin
                        case csite.Status of
                            csite.Status::"DBC ADMIN", csite.status::"HOLD OPERATION", csite.Status::OPERATIONAL:
                                cos.IsActive := true;
                            csite.Status::"PRE-OPENING ", csite.status::"STOP OPERATION":
                                cos.IsActive := false;
                        end;
                        cos.Modify();

                    end;
                until csite.Next() = 0;
            end;

        until comp.Next() = 0;
        cos.Reset();

        message('done');

    end;

    procedure fixstatusfbm()
    var
        csite: record FBM_CustomerSite_C;
        cust: record customer;
    begin

        csite.FindFirst();
        repeat
            csite.CalcFields("Country/Region Code_FF");
            cust.get(csite."Customer No.");
            if (cust."Country/Region Code" = 'PH') or (csite."Country/Region Code_FF" = 'PH') then begin

                csite.Validate(Status, csite.Status::"STOP OPERATION");
                csite.Modify();
            end;
        until csite.Next() = 0;
    end;

    procedure fixexch1D()
    var
        cexch: record "Currency Exchange Rate";
        cexch2: record "Currency Exchange Rate";

    begin


        cexch.SetRange("Starting Date", DMY2Date(27, 09, 2024));
        cexch2.SetRange("Starting Date", DMY2Date(28, 09, 2024));

        if cexch.FindFirst() then
            repeat
                cexch2.SetRange("Currency Code", cexch."Currency Code");
                if cexch2.FindFirst() then begin



                    cexch2."Exchange Rate Amount" := cexch."Exchange Rate Amount";
                    cexch2."Adjustment Exch. Rate Amount" := cexch."Adjustment Exch. Rate Amount";
                    cexch2."Relational Currency Code" := cexch."Relational Currency Code";
                    cexch2."Relational Exch. Rate Amount" := cexch."Relational Exch. Rate Amount";
                    cexch2."Relational Adjmt Exch Rate Amt" := cexch."Relational Adjmt Exch Rate Amt";
                    cexch2."Fix Exchange Rate Amount" := cexch."Fix Exchange Rate Amount";
                    cexch2.Modify();
                end
                else begin
                    cexch2.Init();
                    cexch2."Starting Date" := DMY2Date(28, 09, 2024);
                    cexch2."Currency Code" := cexch."Currency Code";
                    cexch2."Exchange Rate Amount" := cexch."Exchange Rate Amount";
                    cexch2."Adjustment Exch. Rate Amount" := cexch."Adjustment Exch. Rate Amount";
                    cexch2."Relational Currency Code" := cexch."Relational Currency Code";
                    cexch2."Relational Exch. Rate Amount" := cexch."Relational Exch. Rate Amount";
                    cexch2."Relational Adjmt Exch Rate Amt" := cexch."Relational Adjmt Exch Rate Amt";
                    cexch2."Fix Exchange Rate Amount" := cexch."Fix Exchange Rate Amount";
                    cexch2.Insert();
                end;

            until cexch.Next() = 0;
        message('Done 28/9');
        cexch.SetRange("Starting Date", DMY2Date(27, 09, 2024));
        cexch2.SetRange("Starting Date", DMY2Date(29, 09, 2024));

        if cexch.FindFirst() then
            repeat
                cexch2.SetRange("Currency Code", cexch."Currency Code");
                if cexch2.FindFirst() then begin



                    cexch2."Exchange Rate Amount" := cexch."Exchange Rate Amount";
                    cexch2."Adjustment Exch. Rate Amount" := cexch."Adjustment Exch. Rate Amount";
                    cexch2."Relational Currency Code" := cexch."Relational Currency Code";
                    cexch2."Relational Exch. Rate Amount" := cexch."Relational Exch. Rate Amount";
                    cexch2."Relational Adjmt Exch Rate Amt" := cexch."Relational Adjmt Exch Rate Amt";
                    cexch2."Fix Exchange Rate Amount" := cexch."Fix Exchange Rate Amount";
                    cexch2.Modify();
                end else begin
                    cexch2.Init();
                    cexch2."Starting Date" := DMY2Date(29, 09, 2024);
                    cexch2."Currency Code" := cexch."Currency Code";
                    cexch2."Exchange Rate Amount" := cexch."Exchange Rate Amount";
                    cexch2."Adjustment Exch. Rate Amount" := cexch."Adjustment Exch. Rate Amount";
                    cexch2."Relational Currency Code" := cexch."Relational Currency Code";
                    cexch2."Relational Exch. Rate Amount" := cexch."Relational Exch. Rate Amount";
                    cexch2."Relational Adjmt Exch Rate Amt" := cexch."Relational Adjmt Exch Rate Amt";
                    cexch2."Fix Exchange Rate Amount" := cexch."Fix Exchange Rate Amount";
                    cexch2.Insert();
                end;

            until cexch.Next() = 0;
        message('Done 29/9');
    end;

    procedure fixexchday()
    var
        cexch: record "Currency Exchange Rate";
        cexch2: record "Currency Exchange Rate";
        comp: record Company;
        cinfo: record "company Information";
    begin
        comp.findfirst;
        repeat

            cinfo.changecompany(comp.name);
            cinfo.get();
            cexch.changecompany(comp.name);
            cexch2.changecompany(comp.name);
            cexch.SetRange("Starting Date", DMY2Date(20, 04, 2024));
            cexch2.SetRange("Starting Date", DMY2Date(22, 04, 2024));

            if cexch.FindFirst() then
                repeat
                    cexch2.SetRange("Currency Code", cexch."Currency Code");
                    if not cexch2.FindFirst() then begin
                        cexch2.init;
                        cexch2."Starting Date" := DMY2Date(22, 04, 2024);
                        cexch2."Currency Code" := cexch."Currency Code";
                        cexch2."Exchange Rate Amount" := cexch."Exchange Rate Amount";
                        cexch2."Adjustment Exch. Rate Amount" := cexch."Adjustment Exch. Rate Amount";
                        cexch2."Relational Currency Code" := cexch."Relational Currency Code";
                        cexch2."Relational Exch. Rate Amount" := cexch."Relational Exch. Rate Amount";
                        cexch2."Relational Adjmt Exch Rate Amt" := cexch."Relational Adjmt Exch Rate Amt";
                        cexch2."Fix Exchange Rate Amount" := cexch."Fix Exchange Rate Amount";
                        cexch2.Insert();
                    end;

                until cexch.Next() = 0;
            message('Done 22/4');
            // cexch.Reset();
            // cexch2.Reset();
            // cexch.SetRange("Starting Date", DMY2Date(15, 03, 2024));
            // cexch2.SetRange("Starting Date", DMY2Date(17, 03, 2024));

            // if cexch.FindFirst() then
            //     repeat
            //         cexch2.SetRange("Currency Code", cexch."Currency Code");
            //         if not cexch2.FindFirst() then begin
            //             cexch2.init;
            //             cexch2."Starting Date" := DMY2Date(17, 03, 2024);
            //             cexch2."Currency Code" := cexch."Currency Code";
            //             cexch2."Exchange Rate Amount" := cexch."Exchange Rate Amount";
            //             cexch2."Adjustment Exch. Rate Amount" := cexch."Adjustment Exch. Rate Amount";
            //             cexch2."Relational Currency Code" := cexch."Relational Currency Code";
            //             cexch2."Relational Exch. Rate Amount" := cexch."Relational Exch. Rate Amount";
            //             cexch2."Relational Adjmt Exch Rate Amt" := cexch."Relational Adjmt Exch Rate Amt";
            //             cexch2."Fix Exchange Rate Amount" := cexch."Fix Exchange Rate Amount";
            //             cexch2.Insert();
            //         end;

            //     until cexch.Next() = 0;
            // message('Done 9/3');
            // cexch.Reset();
            // cexch2.Reset();
            // cexch.SetRange("Starting Date", DMY2Date(07, 03, 2024));
            // cexch2.SetRange("Starting Date", DMY2Date(10, 03, 2024));

            // if cexch.FindFirst() then
            //     repeat
            //         cexch2.SetRange("Currency Code", cexch."Currency Code");
            //         if not cexch2.FindFirst() then begin
            //             cexch2.init;
            //             cexch2."Starting Date" := DMY2Date(10, 03, 2024);
            //             cexch2."Currency Code" := cexch."Currency Code";
            //             cexch2."Exchange Rate Amount" := cexch."Exchange Rate Amount";
            //             cexch2."Adjustment Exch. Rate Amount" := cexch."Adjustment Exch. Rate Amount";
            //             cexch2."Relational Currency Code" := cexch."Relational Currency Code";
            //             cexch2."Relational Exch. Rate Amount" := cexch."Relational Exch. Rate Amount";
            //             cexch2."Relational Adjmt Exch Rate Amt" := cexch."Relational Adjmt Exch Rate Amt";
            //             cexch2."Fix Exchange Rate Amount" := cexch."Fix Exchange Rate Amount";
            //             cexch2.Insert();
            //         end;


            //     until cexch.Next() = 0;
            message('Done ' + cinfo."Custom System Indicator Text")
        until comp.next = 0;
    end;

    procedure fixcos()
    var
        cos: record FBM_CustOpSite;
        csite: record FBM_CustomerSite_C;
        cinfo: record "Company Information";
        country: record "Country/Region";
        customer: record Customer;
        site: record FBM_Site;
    begin
        cinfo.get;
        cos.SetFilter(Subsidiary, cinfo.FBM_FALessee + '*');
        cos.DeleteAll();
        csite.FindFirst();
        repeat
            cos.init;
            if customer.get(csite."Customer No.") then begin
                cos."Customer No." := customer.FBM_GrCode;
                cos."Operator No." := customer.FBM_GrCode;
                cos."Cust Loc Code" := csite."Customer No.";
                cos."Op Loc Code" := csite."Customer No.";
                cos."Site Loc Code" := csite."Site Code";
                cos."Site Code" := csite.SiteGrCode;
                if (csite.Status = csite.Status::"HOLD OPERATION") or (csite.Status = csite.Status::OPERATIONAL) then
                    cos.IsActive := true
                else
                    cos.IsActive := false;
                cos.Status := csite.Status;
                site.setrange("Site Code", csite.SiteGrCode);
                site.SetRange(ActiveRec, true);
                if site.FindFirst() then begin
                    cos."Valid From" := site."Valid From";
                    cos."Valid To" := site."Valid To";
                    cos."Record Owner" := site."Record Owner";
                    cos."Change Note" := site."Change Note";
                end;
                if country.get(customer."Country/Region Code") then
                    cos.Subsidiary := cinfo.FBM_FALessee + ' ' + country.FBM_Country3
                else
                    cos.Subsidiary := cinfo.FBM_FALessee;
                cos.Insert();
            end;


        until csite.Next() = 0;
    end;

    procedure dataupgrade()
    var
        finattrib: record FBM_FinAttributes;
        custLE: record "Cust. Ledger Entry";
        detcustLE: record "Detailed Cust. Ledg. Entry";
        genjnlline: record "Gen. Journal Line";
        glentry: record "G/L Entry";
        sh: record "Sales Header";
        sih: record "Sales Invoice Header";
        sch: record "Sales Cr.Memo Header";
        comp: record Company;

    begin
        if comp.FindFirst() then
            repeat
                finattrib.ChangeCompany(comp.name);
                if finattrib.FindFirst() then
                    repeat
                        finattrib.FBM_Segment2 := enum::FBM_Segment_DD.FromInteger(finattrib.Segment);
                        if finattrib.segment <> finattrib.Segment::" " then
                            finattrib.Modify();
                    until finattrib.Next() = 0;
                custLE.ChangeCompany(comp.name);
                if custLE.FindFirst() then
                    repeat
                        custLE.FBM_Segment2 := enum::FBM_Segment_DD.FromInteger(custLE.FBM_Segment);
                        if sih.get(custle."Document No.") or sch.get(custle."Document No.") then
                            if custle.FBM_Segment <> custLE.FBM_Segment::" " then
                                custLE.Modify();
                    until custLE.Next() = 0;
                detcustLE.ChangeCompany(comp.name);
                if detcustLE.FindFirst() then
                    repeat
                        detcustLE.FBM_Segment2 := enum::FBM_Segment_DD.FromInteger(detcustLE.FBM_Segment);
                        if sih.get(detcustle."Document No.") or sch.get(detcustle."Document No.") then
                            if detcustle.FBM_Segment <> detcustLE.FBM_Segment::" " then
                                detcustLE.Modify();
                    until detcustLE.Next() = 0;
                genjnlline.ChangeCompany(comp.name);
                if genjnlline.FindFirst() then
                    repeat
                        genjnlline.FBM_Segment2 := enum::FBM_Segment_DD.FromInteger(genjnlline.FBM_Segment);
                        if genjnlline.FBM_Segment <> genjnlline.FBM_Segment::" " then
                            genjnlline.Modify();
                    until genjnlline.Next() = 0;
                glentry.ChangeCompany(comp.name);
                if glentry.FindFirst() then
                    repeat
                        glentry.FBM_Segment2 := enum::FBM_Segment_DD.FromInteger(glentry.FBM_Segment);
                        if glentry.FBM_Segment <> glentry.FBM_Segment::" " then
                            glentry.Modify();
                    until glentry.Next() = 0;
                sh.ChangeCompany(comp.name);
                if sh.FindFirst() then
                    repeat
                        sh.FBM_Segment2 := enum::FBM_Segment_DD.FromInteger(sh.FBM_Segment);
                        if sh.FBM_Segment <> sh.FBM_Segment::" " then
                            sh.Modify();
                    until sh.Next() = 0;
                sih.ChangeCompany(comp.name);
                if sih.FindFirst() then
                    repeat
                        sih.FBM_Segment2 := enum::FBM_Segment_DD.FromInteger(sih.FBM_Segment);
                        if sih.FBM_Segment <> sih.FBM_Segment::" " then
                            sih.Modify();
                    until sih.Next() = 0;
                sch.ChangeCompany(comp.name);
                if sch.FindFirst() then
                    repeat
                        sch.FBM_Segment2 := enum::FBM_Segment_DD.FromInteger(sch.FBM_Segment);
                        if sch.FBM_Segment <> sch.FBM_Segment::" " then
                            sch.Modify();
                    until sch.Next() = 0;
            until comp.next = 0;
        Message('Done');
    end;

    procedure fixline()
    var
        pline: record "Purchase Line";
    begin
        pline.setrange("Document No.", '005719');
        pline.SetRange("Line No.", 10000);
        if pline.FindFirst() then begin
            pline.validate("Qty. Invoiced (Base)", 0);
            pline.validate("Quantity Invoiced", 0);
            pline.Modify();
        end;
    end;

    procedure fixdimtr8()
    var
        pinvheader: record "Purch. Inv. Header";
    begin
        pinvheader.SetRange("No.", 'PPI101265');
        if pinvheader.FindFirst() then begin
            pinvheader."Dimension Set ID" := 8301;
            pinvheader.Modify();
        end;

    end;

    procedure fixfadisp(pfa: code[20])
    var
        dpb: record "FA Depreciation Book";
    begin
        dpb.SetRange("FA No.", pfa);
        if dpb.FindFirst() then begin
            dpb."Disposal Date" := 0D;
            dpb.Modify();
        end;
    end;

    procedure acccontr()
    var
        acc: record "Tenant Media";
    begin
        //acc.SetRange("Company Name", 'FBM SYSTEMS AND ELECTRONICS');
        acc.DeleteAll();
    end;


    procedure fixmx(numdoc: code[20]; amount: Decimal)
    var
        sinv: record "Sales Invoice Header";
    begin
        if sinv.get(numdoc) then begin
            sinv.FBM_Currency2 := 'MXN';
            sinv.FBM_LocalCurrAmt := amount;
            sinv.Modify();
            message('done');
        end;
    end;

    procedure fixprepay()
    var
        pinv: record "Purch. Inv. Header";
    begin
        if pinv.get('PPI102136') then begin
            pinv."Prepayment Invoice" := false;
            pinv.Modify();
        end;
    end;

    procedure fixpoeps()
    var
        ph: record "Purchase Header";
        pl: record "Purchase Line";
    begin
        pl.SetRange("Document Type", ph."Document Type"::Order);
        pl.SetRange("Document No.", 'PO100202');
        pl.ModifyAll("Prepayment %", 0);
        pl.ModifyAll("Prepayment Amount", 0);
        pl.ModifyAll("Prepmt. Line Amount", 0);
        pl.ModifyAll("Prepmt. Amt. Inv.", 0);
        ph.SetRange("Document Type", ph."Document Type"::Order);
        ph.SetRange("No.", 'PO100202');
        if ph.FindFirst() then begin
            ph."Prepayment %" := 0;
            ph.Modify();
        end;
    end;

    procedure fixinvfbm(numdoc: code[20]; importe: decimal)
    var
        sinv: record "Sales Invoice Header";
    begin
        if sinv.get(numdoc) then
            if sinv.FBM_LocalCurrAmt = 0 then begin

                sinv.FBM_Currency2 := 'MXN';
                sinv.FBM_LocalCurrAmt := importe;
                sinv.Modify();
            end;
    end;

    procedure csiteact()
    var
        comp: record Company;
        csite: record FBM_CustomerSite_C;
    begin
        comp.FindFirst();

        repeat
            csite.ChangeCompany(comp.Name);
            if csite.FindFirst() then
                repeat
                    csite.Rename(csite."Customer No.", csite."Site Code", csite.Version, true);
                //    csite.ActiveRec := true;
                //      csite.Modify();
                until csite.next = 0;
        until comp.Next() = 0;

    end;

    procedure createcos()
    var
        csite: record FBM_CustomerSite_C;
        CompanyInfo: record "Company Information";
        customer: record Customer;
        country: record "Country/Region";
        cos: record FBM_CustOpSite;


    begin
        CompanyInfo.get;
        if country.get(CompanyInfo."Country/Region Code") then
            COS.SetRange(Subsidiary, CompanyInfo.FBM_FALessee + ' ' + country.FBM_Country3);
        cos.DeleteAll();
        if csite.FindFirst() then
            repeat
                if csite.ActiveRec then
                    if CompanyInfo.FBM_CustIsOp then begin
                        customer.get(CSite."Customer No.");
                        if country.get(customer."Country/Region Code") then
                            COS.SetRange(Subsidiary, CompanyInfo.FBM_FALessee + ' ' + country.FBM_Country3);
                        cos.SetRange("Customer No.", customer.FBM_GrCode);
                        cos.SetRange("Site Code", '');
                        if cos.findfirst then cos.DeleteAll();
                        cos.Reset();

                        customer.get(CSite."Customer No.");
                        if country.get(customer."Country/Region Code") then
                            COS.SetRange(Subsidiary, CompanyInfo.FBM_FALessee + ' ' + country.FBM_Country3);
                        cos.SetRange("Customer No.", customer.FBM_GrCode);
                        cos.SetRange("Operator No.", customer.FBM_GrCode);
                        cos.SetRange("Site Code", CSite.SiteGrCode);
                        // if (CustSite.Status = CustSite.Status::OPERATIONAL) or (CustSite.Status = CustSite.Status::"HOLD OPERATION") then
                        //     cos.SetRange(ActiveRec, true)
                        // else
                        //     cos.SetRange(ActiveRec, false);
                        //cos.SetRange(Status, xrec.Status);
                        if not cos.FindFirst() then begin
                            COS.Init();
                            COS."Customer No." := customer.FBM_GrCode;
                            COS."Operator No." := customer.FBM_GrCode;
                            COS."Site Code" := CSite.SiteGrCode;
                            cos."Cust Loc Code" := customer."No.";
                            cos.IsActive := true;
                            if (CSite.Status = CSite.Status::OPERATIONAL) or (CSite.Status = CSite.Status::"HOLD OPERATION") then
                                cos.IsActive := true
                            else
                                cos.IsActive := false;
                            cos."Op Loc Code" := customer."No.";
                            cos."Record Owner" := UserId;
                            cos."Site Loc Code" := CSite."Site Code";
                            cos.Status := csite.Status;
                            cos."Valid From" := Today;
                            cos."Valid To" := DMY2Date(31, 12, 2999);
                            CompanyInfo.testfield(FBM_FALessee);
                            // if country.get(customer."Country/Region Code") then begin

                            //     country.testfield(FBM_Country3);
                            cos.Subsidiary := CompanyInfo.FBM_FALessee + ' ' + country.FBM_Country3;

                            // end;
                            COS.Insert();

                        end

                    end;
            until csite.next = 0;
    end;

    procedure cleanmex()
    var
        ile: record "Item Ledger Entry";
        resentry: record "Reservation Entry";
        wentry: record "Warehouse Entry";
        pinvh: record "Purch. Inv. Header";
        pinvl: record "Purch. Inv. Line";
        pcrmh: record "Purch. Cr. Memo Hdr.";
        pcrml: record "Purch. Cr. Memo Line";
        ph: record "Purchase Header";
        pl: record "Purchase Line";
        prech: record "Purch. Rcpt. Header";
        precl: record "Purch. Rcpt. Line";
        gle: record "G/L Entry";
        vate: record "VAT Entry";
        glvat: record "G/L Entry - VAT Entry Link";
        glreg: record "G/L Register";
        item: record Item;
        loc: record Location;
        bin: record Bin;
        binc: record "Bin Content";
        vle: record "Vendor Ledger Entry";
        dvle: record "Detailed Vendor Ledg. Entry";
        rech: record "Invt. Receipt Header";
        recl: record "Invt. Receipt Line";
        shph: record "Invt. Shipment Header";
        shpl: record "Invt. Shipment Line";
        ve: record "Value Entry";

        GLI: Record "G/L - Item Ledger Relation";
        ita: record "Item Application Entry";
        isy: record "Integration Synch. Job Errors";
        isj: record "Integration Synch. Job";
        costa: record "Avg. Cost Adjmt. Entry Point";
        jqle: record "Job Queue Log Entry";
        usloc: record "Warehouse Employee";


    begin
        ile.DeleteAll();
        resentry.DeleteAll();
        wentry.DeleteAll();
        pinvl.DeleteAll();
        pinvh.DeleteAll();
        pcrml.DeleteAll();
        pcrmh.DeleteAll();
        pl.DeleteAll();
        ph.DeleteAll();
        precl.DeleteAll();
        prech.DeleteAll();
        gle.DeleteAll();
        vate.DeleteAll();
        glvat.DeleteAll();
        glreg.DeleteAll();
        item.DeleteAll();
        loc.DeleteAll();
        bin.DeleteAll();
        binc.DeleteAll();
        vle.DeleteAll();
        dvle.DeleteAll();
        recl.DeleteAll();
        rech.DeleteAll();
        shpl.DeleteAll();
        shph.DeleteAll();
        ve.DeleteAll();
        gli.DeleteAll();
        ita.DeleteAll();
        isj.DeleteAll();
        isy.DeleteAll();
        costa.DeleteAll();
        jqle.DeleteAll();
        usloc.DeleteAll();
        message('done');




    end;

    procedure cleanmex2()
    var
        actc: record "Activities Cue";
        ijl: record "Item Journal Line";
        it: record Item;
        assl: record "Assembly Line";
        assh: record "Assembly Header";
        fa: record "Fixed Asset";
        ptrh: record "Direct Trans. Header";
        ptrl: record "Direct Trans. Line";
    begin

        ptrl.DeleteAll();
        ptrh.DeleteAll();

    end;

    procedure fixmex()
    var
        sinv: record "Sales Invoice Header";
        sinvl: record "Sales Invoice Line";
        cle: record "Cust. Ledger Entry";
        dcle: record "Detailed Cust. Ledg. Entry";
        vate: record "VAT Entry";
        gle: record "G/L Entry";
        ve: record "Value Entry";
    begin
        sinv.SetRange("No.", '2024-1295');
        if sinv.FindFirst() then begin
            sinv.validate("Bill-to Customer No.", 'MX0067');
            sinv.Validate("Sell-to Customer No.", 'MX0067');
            sinv.validate(FBM_Site, 'MX0067-0003');

            sinv.Modify();
        end;

        sinvl.SetRange("Document No.", '2024-1295');
        if sinvl.FindFirst() then
            repeat
                sinvl.Validate("Bill-to Customer No.", 'MX0067');
                sinvl.Validate("Sell-to Customer No.", 'MX0067');
                sinvl.Validate(FBM_Site, 'MX0067-0003');
                sinvl.Modify();
            until sinvl.Next() = 0;

        cle.SetRange("Document No.", '2024-1295');
        if cle.FindFirst() then
            repeat
                cle.Validate("Customer No.", 'MX0067');
                cle.Validate(FBM_Site, 'MX0067-0003');
                cle.Modify();
            until cle.next() = 0;

        dcle.SetRange("Document No.", '2024-1295');
        if dcle.FindFirst() then
            repeat
                dcle.Validate("Customer No.", 'MX0067');
                dcle.Validate(FBM_Site, 'MX0067-0003');
                dcle.Modify();
            until dcle.next() = 0;

        vate.SetRange("Document No.", '2024-1295');
        if vate.FindFirst() then
            repeat
                vate.Validate("Bill-to/Pay-to No.", 'MX0067');
                vate.Modify();
            until vate.next() = 0;
        gle.SetRange("Document No.", '2024-1295');
        if gle.FindFirst() then
            repeat
                gle.Validate("Source No.", 'MX0067');
                gle.Validate(FBM_Site, 'MX0067-0003');
                gle.Modify();
            until gle.next() = 0;
        ve.SetRange("Document No.", '2024-1295');
        if ve.FindFirst() then
            repeat
                ve.Validate("Source No.", 'MX0067');
                ve.Modify();
            until ve.next() = 0;

    end;

    procedure setcompany()
    var
        comp: record Company;
        cinfo: record "Company Information";
        masterc: record FBM_Customer;
        masters: record FBM_Site;
        cust: record Customer;
        csite: record FBM_CustomerSite_C;
    begin
        comp.FindFirst();
        masterc.FindFirst();
        masterc.ModifyAll(FBM_Company1, '');
        masterc.ModifyAll(FBM_Company2, '');
        masterc.ModifyAll(FBM_Company3, '');
        masters.ModifyAll(Company1, '');
        masters.ModifyAll(Company2, '');
        masters.ModifyAll(Company3, '');
        repeat
            cinfo.ChangeCompany(comp.name);
            cust.ChangeCompany(comp.name);
            csite.ChangeCompany(comp.Name);
            cinfo.get();

            masterc.FindFirst();
            repeat

                cust.setrange(FBM_GrCode, masterc."No.");
                if not cust.IsEmpty then begin
                    if (masterc.FBM_Company1 <> cinfo."Custom System Indicator Text") and
                    (masterc.FBM_Company2 <> cinfo."Custom System Indicator Text") and
                    (masterc.FBM_Company3 <> cinfo."Custom System Indicator Text") and
                    not ((masterc."Country/Region Code" = 'PH') and (cinfo."Custom System Indicator Text" = 'FBM')) then begin
                        if masterc.FBM_Company1 = '' then
                            masterc.FBM_Company1 := cinfo."Custom System Indicator Text" else
                            if masterc.FBM_Company2 = '' then
                                masterc.FBM_Company2 := cinfo."Custom System Indicator Text" else
                                if masterc.FBM_Company3 = '' then masterc.FBM_Company2 := cinfo."Custom System Indicator Text";
                        masterc.Modify();

                    end;

                end;
                if (masterc.FBM_Company1 = 'FBM') and (masterc."Country/Region Code" = 'MX') then begin
                    masterc.FBM_Company2 := 'JYM';
                    masterc.Modify();
                end;
            until masterc.Next() = 0;


            masters.FindFirst();
            repeat
                csite.setrange(SiteGrCode, masters."Site Code");
                if not csite.IsEmpty then begin
                    if (masters.Company1 <> cinfo."Custom System Indicator Text") and
                    (masters.Company2 <> cinfo."Custom System Indicator Text") and
                    (masters.Company3 <> cinfo."Custom System Indicator Text") and
                      not ((masters."Country/Region Code" = 'PH') and (cinfo."Custom System Indicator Text" = 'FBM')) then begin
                        if masters.Company1 = '' then
                            masters.Company1 := cinfo."Custom System Indicator Text" else
                            if masters.Company2 = '' then
                                masters.Company2 := cinfo."Custom System Indicator Text" else
                                if masters.Company3 = '' then masters.Company2 := cinfo."Custom System Indicator Text";
                        masters.Modify();

                    end;

                end;
                if (masters.Company1 = 'FBM') and (masters."Country/Region Code" = 'MX') then begin
                    masters.Company2 := 'JYM';
                    masters.Modify();
                end;
            until masters.Next() = 0;

        until comp.Next() = 0;
    end;

    procedure fixier()
    var
        ier: record "Item Entry Relation";
        ile: record "Item Ledger Entry";
        dtl: record "Direct Trans. Line";
        dth: record "Direct Trans. Header";

    begin
        ier.FindFirst();
        repeat
            if not ile.get(ier."Item Entry No.") then ier.delete;
        until ier.Next() = 0;
        dtl.DeleteAll();
        dth.DeleteAll();
        message('done');
    end;

    procedure dateacqfa()

    begin
        //fa.SetRange("FA Subclass Code", 'EGM_MX');
        fa.FindFirst();
        // repeat
        //     FA.CalcFields(FBM_AcqCost);
        //     FA.FBM_AcquisitionCost := FA.FBM_AcqCost;
        //     fa.Version += 1;
        //     fa.Modify();
        // until fa.Next() = 0;
        fa.Reset();
        FileManagement.BLOBImportWithFilter(TempBlob, ImportFileLbl, '', FileManagement.GetToFilterText('', '.xlsx'), 'xlsx');

        // Select sheet from the excel file
        TempBlob.CreateInStream(FileInStream);
        SheetName := TempExcelBuffer.SelectSheetsNameStream(FileInStream);

        // Open selected sheet
        TempBlob.CreateInStream(FileInStream);
        ErrorMessage := TempExcelBuffer.OpenBookStream(FileInStream, SheetName);
        if ErrorMessage <> '' then
            Error(ErrorMessage);

        TempExcelBuffer.ReadSheet();
        rn := 1;
        if TempExcelBuffer.FindSet() then
            repeat
                rn += 1;
                insertdatatot(rn);
            until TempExcelBuffer.Next() < 1;
    end;

    procedure GetValueAtCell(RowNo: Integer; ColNo: Integer): Text

    begin

        if Tempexcelbuffer.get(RowNo, ColNo) then
            exit(Tempexcelbuffer."Cell Value as Text");
    end;

    procedure insertdata(rowNo: Integer)
    var
        dtxt: Text;
        no: code[20];
        d: Integer;
        m: Integer;
        y: Integer;
    begin

        evaluate(no, GetValueAtCell(rowNo, 1));
        fa.SetRange("No.", no);
        if fa.FindFirst() then begin
            dtxt := GetValueAtCell(rowNo, 2);
            evaluate(d, copystr(dtxt, 9, 2));
            evaluate(m, copystr(dtxt, 6, 2));
            evaluate(y, '20' + copystr(dtxt, 3, 2));
            fa.validate(FBM_AcquisitionDate, DMY2Date(d, m, y));
            //ile.validate(FBM_Pedimentobis, GetValueAtCell(rowNo, 3));
            fa.Modify();
        end;
        commit;

    end;

    procedure insertdatatot(rowNo: Integer)
    var
        dtxt: Text;
        no: code[20];
        d: Integer;
        m: Integer;
        y: Integer;
        vtxt: Text;
        csite: record FBM_CustomerSite_C;
    begin

        evaluate(no, GetValueAtCell(rowNo, 3));
        fa.SetRange("No.", no);
        if fa.FindFirst() then begin
            dtxt := GetValueAtCell(rowNo, 17);//acqdate
            evaluate(d, copystr(dtxt, 1, 2));
            evaluate(m, copystr(dtxt, 4, 2));
            evaluate(y, '20' + copystr(dtxt, 9, 2));
            fa.validate(FBM_AcquisitionDate, DMY2Date(d, m, y));
            vtxt := GetValueAtCell(rowNo, 7);//brand
            evaluate(fa.fbm_brand, vtxt);
            vtxt := GetValueAtCell(rowNo, 8);//lessee
            evaluate(fa.FBM_Lessee, vtxt);
            vtxt := GetValueAtCell(rowNo, 9);//site
            evaluate(fa.FBM_Site, vtxt);
            csite.SetRange(SiteGrCode, vtxt);

            vtxt := GetValueAtCell(rowNo, 15);//status
            evaluate(fa.FBM_Status, vtxt);
            vtxt := GetValueAtCell(rowNo, 18);//acq cost
            evaluate(fa.FBM_AcquisitionCost, vtxt);
            vtxt := GetValueAtCell(rowNo, 19);//model
            evaluate(fa.FBM_Model, vtxt);
            vtxt := GetValueAtCell(rowNo, 20);//segment
            evaluate(fa.FBM_Segment2, vtxt);
            dtxt := GetValueAtCell(rowNo, 21);//prep date
            evaluate(d, copystr(dtxt, 1, 2));
            evaluate(m, copystr(dtxt, 4, 2));
            evaluate(y, '20' + copystr(dtxt, 9, 2));
            fa.validate(FBM_DatePrepared, DMY2Date(d, m, y));
            vtxt := GetValueAtCell(rowNo, 22);//fa location
            evaluate(fa."FA Location Code", vtxt);
            fa.Modify();
        end;
        commit;

    end;

    procedure cleanFAMX()
    var
        fa: record "Fixed Asset";
    begin
        fa.SetRange("FA Subclass Code", 'EGM_MX');
        IF CONFIRM(FORMAT(FA.COUNT())) THEN
            FA.DeleteAll();
        MESSAGE('DONE');

    end;

    procedure incver()
    var
        fa: record "Fixed Asset";
    begin
        fa.SetRange("FA Subclass Code", 'EGM_MX');
        IF FA.FindFirst() then BEGIN
            FA.VERSION := 9;
            FA.Modify();
        END;
    end;

    procedure CARGAPED()

    begin
        //fa.SetRange("FA Subclass Code", 'EGM_MX');
        fa.FindFirst();
        // repeat
        //     FA.CalcFields(FBM_AcqCost);
        //     FA.FBM_AcquisitionCost := FA.FBM_AcqCost;
        //     fa.Version += 1;
        //     fa.Modify();
        // until fa.Next() = 0;
        fa.Reset();
        FileManagement.BLOBImportWithFilter(TempBlob, ImportFileLbl, '', FileManagement.GetToFilterText('', '.xlsx'), 'xlsx');

        // Select sheet from the excel file
        TempBlob.CreateInStream(FileInStream);
        SheetName := TempExcelBuffer.SelectSheetsNameStream(FileInStream);

        // Open selected sheet
        TempBlob.CreateInStream(FileInStream);
        ErrorMessage := TempExcelBuffer.OpenBookStream(FileInStream, SheetName);
        if ErrorMessage <> '' then
            Error(ErrorMessage);

        TempExcelBuffer.ReadSheet();
        rn := 1;
        if TempExcelBuffer.FindSet() then
            repeat
                rn += 1;
                insertdataped(rn);
            until TempExcelBuffer.Next() < 1;
    end;



    procedure insertdataped(rowNo: Integer)
    var
        dtxt: Text;
        no: code[20];
        ser: text[100];
        ile: record "Item Ledger Entry";
    begin

        evaluate(no, GetValueAtCell(rowNo, 1));
        evaluate(ser, GetValueAtCell(rowNo, 2));
        ile.SetRange("Item No.", no);
        ile.SetRange("Serial No.", ser);

        if ile.FindFirst() then begin
            dtxt := GetValueAtCell(rowNo, 3);
            REPEAT
                ile.validate(FBM_Pedimento_2, dtxt);
                //ile.validate(FBM_Pedimentobis, GetValueAtCell(rowNo, 3));
                ile.Modify();
            UNTIL ile.next = 0;
        end;
        commit;

    end;

    procedure fixppi(rr: Boolean; ndoc: code[20])
    var
        pinv: record "Purch. Inv. Header";
        gle: record "G/L Entry";
        ve: record "VAT Entry";
        vle: record "Vendor Ledger Entry";
        dvle: record "Detailed Vendor Ledg. Entry";
        fale: record "FA Ledger Entry";
        cf: Decimal;
        exr: record "Currency Exchange Rate";
        linv: record "Purch. Inv. Line";
        rate: decimal;
        edate: date;
        fad: record "FA Depreciation Book";
    begin
        pinv.SetRange("No.", ndoc);
        if pinv.FindFirst() then begin
            cf := pinv."Currency Factor";
            gle.SetRange("Document No.", ndoc);
            if gle.FindFirst() then
                if rr then
                    repeat
                        gle.Validate(Amount, round(gle.Amount * cf, 1));

                        gle."Additional-Currency Amount" := gle.Amount / CF;
                        gle.Modify();
                    until gle.next = 0
                else begin
                    linv.setrange("Document No.", ndoc);

                    repeat

                        if linv.FindFirst() then begin
                            gle.Validate(Amount, linv.Amount);

                            gle."Additional-Currency Amount" := gle.Amount / CF;
                            gle.Modify();
                            linv.Next();
                        end;
                    until gle.next = 0;
                end;

            ve.SetRange("Document No.", ndoc);
            if ve.FindFirst() then
                if rr then
                    repeat

                        ve.Validate(base, round(ve.base * cf, 1));

                        ve.Modify();
                    until ve.Next() = 0
                else begin
                    linv.setrange("Document No.", ndoc);

                    repeat

                        if linv.FindFirst() then
                            ve.Validate(Amount, linv.Amount);
                        ve.Modify();
                        linv.Next();
                    until ve.next = 0;
                end;

            vle.SetRange("Document No.", ndoc);
            if vle.FindFirst() then
                if rr then begin
                    vle."Amount (LCY)" := vle."Original Amount";

                    vle.Modify(false);
                end;
            dvle.SetRange("Document No.", ndoc);
            if dvle.FindFirst() then begin
                dvle."Amount (LCY)" := dvle."Amount";

                dvle.Modify();
            end;
            dvle.reset;
            DVLE.SetRange("Vendor Ledger Entry No.", VLE."Entry No.");
            IF DVLE.FindFirst() then
                repeat
                    dvle."Amount (LCY)" := dvle.Amount;
                    dvle.Modify();
                until dvle.next = 0;
            ;
            fale.SetRange("Document No.", ndoc);

            if fale.FindFirst() then
                if rr then
                    repeat
                        fale.Validate(Amount, round(fale.Amount * cf, 1));

                        fale.Modify();
                    until fale.next = 0
                else begin
                    linv.setrange("Document No.", ndoc);

                    repeat

                        if linv.FindFirst() then
                            fale.Validate(Amount, linv.Amount);
                        fale.Modify();
                        linv.Next();
                    until fale.next = 0;
                end;


            pinv."Currency Factor" := 1;
            pinv.Modify();

        end;
        fad.SetRange("FA No.", 'FA00047');
        if fad.FindFirst() then begin
            fad."Disposal Date" := 0D;
            fad.Modify();
        end;
    end;
}
