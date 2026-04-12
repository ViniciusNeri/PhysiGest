import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:physigest/features/patients/domain/models/patient.dart';
import 'package:physigest/core/utils/currency_formatter.dart';

class PdfReceiptGenerator {
  static Future<void> generateAndPrint(
    String patientName,
    PatientPayment tx,
    String displayDate,
    String displayMethod,
  ) async {
    final pdf = pw.Document();

    final primaryColor = PdfColor.fromHex('#7C3AED'); // Cor do Sistema do PhysiGest (Roxo)
    final secondaryColor = PdfColor.fromHex('#9370DB'); // Roxo Claro
    final accentColor = PdfColor.fromHex('#10B981'); // Verde
    
    // Extrai apenas a data se tiver horário incluso
    final justDate = displayDate.split(' às').first;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // HEADER BANNER
              pw.Container(
                color: primaryColor,
                padding: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 40),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'PhysiGest',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 32,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        pw.Text(
                          'Gestão inteligente',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 10,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white.withAlpha(0.2),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                      ),
                      child: pw.Text(
                        'RECIBO',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // BODY SECTION
              pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 40),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // INFO BOX 1: RECEIPT DETAILS
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('DATA DE EMISSÃO', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                              pw.SizedBox(height: 4),
                              pw.Text(justDate, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text('CÓDIGO DA TRANSAÇÃO', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                              pw.SizedBox(height: 4),
                              pw.Text(tx.id.length > 8 ? tx.id.substring(0, 8).toUpperCase() : tx.id.toUpperCase(), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      
                      pw.SizedBox(height: 40),

                      // PATIENT INFO
                      pw.Text('DADOS DO PACIENTE', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                      pw.SizedBox(height: 8),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(16),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey100,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                        ),
                        child: pw.Row(
                          children: [
                            pw.Text('Nome:  ', style: pw.TextStyle(color: PdfColors.grey700)),
                            pw.Text(patientName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ),

                      pw.SizedBox(height: 40),

                      // SERVICES TABLE
                      pw.Text('DETALHAMENTO DO SERVIÇO', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                      pw.SizedBox(height: 8),
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                        ),
                        child: pw.Column(
                          children: [
                            // Table Header
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.grey200,
                                borderRadius: const pw.BorderRadius.only(
                                  topLeft: pw.Radius.circular(8),
                                  topRight: pw.Radius.circular(8),
                                ),
                              ),
                              child: pw.Row(
                                children: [
                                  pw.Expanded(flex: 3, child: pw.Text('DESCRIÇÃO', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700))),
                                  pw.Expanded(flex: 1, child: pw.Text('QTDE', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700))),
                                  pw.Expanded(flex: 2, child: pw.Text('VALOR', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700))),
                                ],
                              ),
                            ),
                            // Table Row
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(16),
                              child: pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Expanded(
                                    flex: 3, 
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(tx.category, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                                        if (tx.description.isNotEmpty) ...[
                                          pw.SizedBox(height: 4),
                                          pw.Text(tx.description, style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
                                        ],
                                        pw.SizedBox(height: 8),
                                        pw.Text('Data de Confirmação: $displayDate', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500)),
                                      ],
                                    ),
                                  ),
                                  pw.Expanded(
                                    flex: 1, 
                                    child: pw.Text('${tx.totalSessions} Sessõe(s)', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 14)),
                                  ),
                                  pw.Expanded(
                                    flex: 2, 
                                    child: pw.Text(CurrencyFormatter.format(tx.amount), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      pw.SizedBox(height: 32),

                      // TOTALS & STAMP
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Payment Method
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('FORMA DE PAGAMENTO', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                                pw.SizedBox(height: 4),
                                pw.Text(displayMethod, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                              ],
                            ),
                          ),
                          
                          // Total Box
                          pw.Container(
                            width: 200,
                            padding: const pw.EdgeInsets.all(16),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.grey100,
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                              border: pw.Border.all(color: accentColor, width: 2),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Text('TOTAL PAGO', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  CurrencyFormatter.format(tx.amount), 
                                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: accentColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      pw.Spacer(),
                      
                      // SIGNATURE/FOOTER
                      pw.Divider(color: PdfColors.grey300),
                      pw.SizedBox(height: 16),
                      pw.Center(
                        child: pw.Text(
                          'Atestamos para os devidos fins que recebemos da pessoa acima identificada a quantia supra-citada.',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic),
                        ),
                      ),
                      pw.SizedBox(height: 24),
                      pw.Center(
                        child: pw.Text(
                          'Gerado por PhysiGest',
                          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: secondaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Recibo_PhysiGest_${tx.id}.pdf',
    );
  }
}
