import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:physigest/core/di/injection.dart';
import 'package:physigest/features/patients/domain/models/patient.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_bloc.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_event.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_state.dart';

class PatientProfileScreen extends StatefulWidget {
  final Patient patient;

  const PatientProfileScreen({super.key, required this.patient});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();

  // CORES PREMIUM
  static const Color primaryGradStart = Color(0xFF2DD4BF); 
  static const Color primaryGradEnd = Color(0xFF0D9488);   
  static const Color secondaryGradStart = Color(0xFFA78BFA); 
  static const Color secondaryGradEnd = Color(0xFF7C3AED);   
  static const Color background = Color(0xFFF1F5F9); 
  static const Color cardBG = Colors.white;
  static const Color textMain = Color(0xFF1E293B); 
  static const Color textSecondary = Color(0xFF94A3B8); 
  static const Color borderColor = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<PatientBloc>(),
      child: BlocBuilder<PatientBloc, PatientState>(
        builder: (context, state) {
          final currentPatient = state.patients.firstWhere(
            (p) => p.id == widget.patient.id,
            orElse: () => widget.patient,
          );

          return Scaffold(
            backgroundColor: background,
            appBar: _buildAppBar(currentPatient),
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildResumoTab(currentPatient),
                _buildAgendaTab(currentPatient),
                _buildAnamnesisTab(context, currentPatient),
                _buildFinanceiroTab(currentPatient),
                _buildPlaceholder(Icons.description, "Anexos em Breve"),
                _buildGalleryTab(context, currentPatient),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Patient p) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AppBar(
            backgroundColor: Colors.white.withOpacity(0.8),
            elevation: 0,
            iconTheme: const IconThemeData(color: textMain),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: const TextStyle(color: textMain, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5)),
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text("Prontuário Digital Ativo", style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: secondaryGradEnd,
              indicatorWeight: 4,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: primaryGradEnd,
              unselectedLabelColor: textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
              tabs: const [
                Tab(text: 'RESUMO'), Tab(text: 'AGENDA'), Tab(text: 'ANAMNESE'),
                Tab(text: 'FINANCEIRO'), Tab(text: 'ANEXOS'), Tab(text: 'FOTOS'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- ABA 1: RESUMO ---
  Widget _buildResumoTab(Patient p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildSidebarProfile(p)),
              const SizedBox(width: 32),
              Expanded(
                flex: 7,
                child: Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Column(
                    children: [
                      _buildPremiumStatsRow(),
                      const SizedBox(height: 32),
                      _buildAnamnesisQuickView(p),
                      const SizedBox(height: 32),
                      _buildHistoryCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- ABA 2: AGENDA ---
  Widget _buildAgendaTab(Patient p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Histórico de Atendimentos", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textMain)),
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: primaryGradEnd, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text("NOVO AGENDAMENTO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              _buildTimelineItem("05 Mar 2026", "14:00", "Reavaliação Muscular", "Agendado", Colors.orange),
              _buildTimelineItem("26 Fev 2026", "10:30", "Sessão de Fisioterapia", "Concluído", primaryGradEnd),
              _buildTimelineItem("19 Fev 2026", "10:30", "Sessão de Fisioterapia", "Concluído", primaryGradEnd),
              _buildTimelineItem("12 Fev 2026", "09:00", "Avaliação Inicial", "Concluído", secondaryGradEnd, isLast: true),
            ],
          ),
        ),
      ),
    );
  }

  // --- ABA 3: ANAMNESE ---
  Widget _buildAnamnesisTab(BuildContext context, Patient p) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 240,
          decoration: const BoxDecoration(border: Border(right: BorderSide(color: borderColor))),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildAnamnesisNavLabel("TÓPICOS", isHeader: true),
              _buildAnamnesisNavItem("Queixa Principal", true),
              _buildAnamnesisNavItem("Sinais Vitais", false),
              _buildAnamnesisNavItem("Histórico Clínico", false),
              _buildAnamnesisNavItem("Medicamentos", false),
              _buildAnamnesisNavItem("Exame Físico", false),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(48),
            children: [
              _buildSectionHeader("Avaliação Clínica Contemporânea", "Última atualização: Hoje às 10:45"),
              const SizedBox(height: 32),
              Row(
                children: [
                  _buildVitalInput("Peso", "kg", "74.0"),
                  const SizedBox(width: 16),
                  _buildVitalInput("Altura", "cm", "178"),
                  const SizedBox(width: 16),
                  _buildVitalInput("IMC", "índice", "23.4", readOnly: true),
                  const SizedBox(width: 16),
                  _buildVitalInput("Pressão", "mmHg", "12/8"),
                ],
              ),
              const SizedBox(height: 40),
              _buildProfessionalEditSection(
                title: "Queixa Principal e HDA",
                subtitle: "Descrição detalhada do motivo da consulta",
                icon: Icons.assignment_late_rounded,
                initialValue: p.anamnesis.mainComplaint,
                colors: [primaryGradStart, primaryGradEnd],
                onSave: (val) {
                  final newAnamnesis = p.anamnesis.copyWith(mainComplaint: val);
                  context.read<PatientBloc>().add(UpdatePatient(p.copyWith(anamnesis: newAnamnesis)));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- ABA 4: FINANCEIRO (COM HISTÓRICO) ---
  Widget _buildFinanceiroTab(Patient p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Gestão Financeira", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: textMain)),
                      Text("Controle de saldos e vendas", style: TextStyle(color: textSecondary)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.receipt_long_rounded, size: 18, color: Colors.white),
                    label: const Text("GERAR RECIBO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: secondaryGradEnd, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Cards de Saldo
              Row(
                children: [
                  _buildFinanceCard("Saldo Devedor", "R\$ 350,00", Icons.warning_amber_rounded, Colors.redAccent),
                  const SizedBox(width: 20),
                  _buildFinanceCard("Sessões Restantes", "04", Icons.confirmation_number_outlined, Colors.blueAccent),
                  const SizedBox(width: 20),
                  _buildFinanceCard("Total Investido", "R\$ 4.800", Icons.insights_rounded, Colors.teal),
                ],
              ),
              const SizedBox(height: 48),
              // Pacotes
              const Text("Pacotes Disponíveis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textMain)),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildPackageCard("Básico", "5 Sessões", "R\$ 750", "R\$ 150/sessão", primaryGradStart),
                  const SizedBox(width: 20),
                  _buildPackageCard("Intermediário", "10 Sessões", "R\$ 1.300", "R\$ 130/sessão", secondaryGradStart),
                  const SizedBox(width: 20),
                  _buildPackageCard("Premium", "20 Sessões", "R\$ 2.200", "R\$ 110/sessão", const Color(0xFFF59E0B)),
                ],
              ),
              const SizedBox(height: 48),
              // HISTÓRICO DE COMPRAS (NOVO)
              const Text("Histórico de Transações", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textMain)),
              const SizedBox(height: 20),
              _buildTransactionHistory(),
            ],
          ),
        ),
      ),
    );
  }

  // --- COMPONENTES DO HISTÓRICO FINANCEIRO ---
  Widget _buildTransactionHistory() {
    return Container(
      decoration: BoxDecoration(
        color: cardBG,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _buildTransactionRow("Pacote Intermediário (10 sessões)", "28 Fev 2026", "R\$ 1.300,00", "Pago", Colors.green),
          const Divider(height: 1, indent: 24, endIndent: 24),
          _buildTransactionRow("Avaliação Clínica Avulsa", "12 Fev 2026", "R\$ 250,00", "Pago", Colors.green),
          const Divider(height: 1, indent: 24, endIndent: 24),
          _buildTransactionRow("Sessão Extra - Liberação", "05 Fev 2026", "R\$ 180,00", "Pendente", Colors.orange),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(String title, String date, String value, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.shopping_bag_outlined, color: textMain.withOpacity(0.7), size: 20),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: textMain, fontSize: 15)),
                Text(date, style: const TextStyle(color: textSecondary, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w900, color: textMain, fontSize: 16)),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES REUTILIZADOS ---

  Widget _buildSidebarProfile(Patient p) {
    final br = BorderRadius.circular(32);
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: br, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)]),
      child: ClipRRect(
        borderRadius: br,
        child: Column(children: [
          Container(width: double.infinity, decoration: const BoxDecoration(gradient: LinearGradient(colors: [primaryGradStart, primaryGradEnd])), padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24), child: Column(children: [CircleAvatar(radius: 50, backgroundColor: Colors.white, child: Text(p.name[0].toUpperCase(), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: primaryGradEnd))), const SizedBox(height: 24), Text(p.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white))])),
          Padding(padding: const EdgeInsets.all(32), child: Column(children: [_buildSidebarTile(Icons.phone_android_rounded, "Telefone", p.phone, const Color(0xFFE0F2FE), Colors.blue), _buildSidebarTile(Icons.alternate_email_rounded, "E-mail", p.email, const Color(0xFFFFF7ED), Colors.orange), _buildSidebarTile(Icons.work_outline_rounded, "Profissão", p.occupation, const Color(0xFFF0FDFA), Colors.teal)]))
        ]),
      ),
    );
  }

  Widget _buildTimelineItem(String d, String h, String t, String s, Color c, {bool isLast = false}) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [Container(width: 18, height: 18, decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4))), if (!isLast) Container(width: 2, height: 70, color: borderColor)]),
      const SizedBox(width: 25),
      Expanded(child: Container(margin: const EdgeInsets.only(bottom: 25), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: cardBG, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor)), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(d, style: const TextStyle(fontWeight: FontWeight.w800, color: textSecondary, fontSize: 12)), Text(t, style: const TextStyle(fontWeight: FontWeight.w900, color: textMain, fontSize: 16)), Row(children: [Icon(Icons.access_time_rounded, size: 14, color: textSecondary), const SizedBox(width: 5), Text(h, style: const TextStyle(color: textSecondary, fontSize: 12))])])), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Text(s.toUpperCase(), style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 10)))])))
    ]);
  }

  Widget _buildFinanceCard(String t, String v, IconData i, Color c) => Expanded(child: Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: cardBG, borderRadius: BorderRadius.circular(24), border: Border.all(color: borderColor)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(i, color: c, size: 28), const SizedBox(height: 16), Text(v, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textMain)), Text(t, style: const TextStyle(color: textSecondary, fontWeight: FontWeight.w600))])));
  
  Widget _buildPackageCard(String n, String s, String p, String d, Color c) => Expanded(child: Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: cardBG, borderRadius: BorderRadius.circular(24), border: Border.all(color: c.withOpacity(0.3), width: 2)), child: Column(children: [Text(n, style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 14)), const SizedBox(height: 8), Text(s, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 16), Text(p, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textMain)), Text(d, style: const TextStyle(color: textSecondary, fontSize: 12)), const SizedBox(height: 20), ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: c, minimumSize: const Size(double.infinity, 45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("VENDER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))])));

  Widget _buildProfessionalEditSection({required String title, required String subtitle, required IconData icon, required String initialValue, required List<Color> colors, required Function(String) onSave}) => Container(decoration: BoxDecoration(color: cardBG, borderRadius: BorderRadius.circular(24), border: Border.all(color: borderColor)), child: Column(children: [ListTile(leading: Icon(icon, color: colors[1]), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(subtitle)), const Divider(), Padding(padding: const EdgeInsets.all(24), child: TextFormField(initialValue: initialValue, maxLines: null, minLines: 4, onChanged: onSave, style: const TextStyle(fontSize: 15, height: 1.6, color: textMain), decoration: InputDecoration(fillColor: const Color(0xFFF8FAFC), filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))))]));

  Widget _buildVitalInput(String l, String u, String i, {bool readOnly = false}) => Expanded(child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: readOnly ? background : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textSecondary)), const SizedBox(height: 8), Row(children: [Expanded(child: TextFormField(initialValue: i, readOnly: readOnly, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textMain), decoration: const InputDecoration(isDense: true, border: InputBorder.none))), Text(u, style: const TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.bold))])])));
  
  Widget _buildHistoryCard() => Container(padding: const EdgeInsets.all(32), decoration: BoxDecoration(color: cardBG, borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Histórico Recente", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textMain)), const SizedBox(height: 16), _buildColorHistoryItem("Consulta de Avaliação", "26/02/2026", primaryGradEnd), _buildColorHistoryItem("Sessão de Fisioterapia", "12/02/2026", primaryGradEnd)]));
  
  Widget _buildColorHistoryItem(String t, String d, Color c) => Padding(padding: const EdgeInsets.only(bottom: 16), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: c.withOpacity(0.03), borderRadius: BorderRadius.circular(16), border: Border.all(color: c.withOpacity(0.1))), child: Row(children: [Icon(Icons.check_circle_rounded, color: c, size: 20), const SizedBox(width: 16), Expanded(child: Text(t, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: textMain))), Text(d, style: const TextStyle(color: textSecondary, fontSize: 12))])));

  Widget _buildPremiumStatsRow() => Row(children: [_buildGradientStatCard("12", "Sessões", Icons.verified_rounded, [primaryGradStart, primaryGradEnd]), const SizedBox(width: 16), _buildGradientStatCard("R\$ 1.250", "Investido", Icons.account_balance_wallet_rounded, [secondaryGradStart, secondaryGradEnd]), const SizedBox(width: 16), _buildGradientStatCard("05/03", "Próxima", Icons.event_available_rounded, [const Color(0xFFFBBF24), const Color(0xFFF59E0B)])]);

  Widget _buildGradientStatCard(String v, String l, IconData i, List<Color> c) => Expanded(child: Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: cardBG, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: c[1].withOpacity(0.1), blurRadius: 15)]), child: Row(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(gradient: LinearGradient(colors: c), borderRadius: BorderRadius.circular(16)), child: Icon(i, color: Colors.white, size: 22)), const SizedBox(width: 16), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(v, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textMain)), Text(l, style: const TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w700))])])));

  Widget _buildAnamnesisQuickView(Patient p) => Container(width: double.infinity, padding: const EdgeInsets.all(32), decoration: BoxDecoration(color: cardBG, borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Últimas Observações", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 16), Text(p.anamnesis.mainComplaint, style: const TextStyle(color: textSecondary, height: 1.5))]));
  
  Widget _buildGalleryTab(BuildContext context, Patient patient) => Column(children: [Expanded(child: patient.photoPaths.isEmpty ? _buildPlaceholder(Icons.add_a_photo_rounded, "Sem fotos") : GridView.builder(padding: const EdgeInsets.all(32), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 20, mainAxisSpacing: 20), itemCount: patient.photoPaths.length, itemBuilder: (context, index) => ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.file(File(patient.photoPaths[index]), fit: BoxFit.cover)))), Container(padding: const EdgeInsets.all(24), child: ElevatedButton(onPressed: () {}, child: const Text("CAPTURAR NOVA FOTO")))]);

  Widget _buildSidebarTile(IconData i, String l, String v, Color bg, Color ic) => Padding(padding: const EdgeInsets.only(bottom: 20), child: Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)), child: Icon(i, color: ic, size: 20)), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: const TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.bold)), Text(v, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))])]));
  Widget _buildAnamnesisNavItem(String l, bool a) => ListTile(title: Text(l, style: TextStyle(color: a ? primaryGradEnd : textSecondary, fontWeight: a ? FontWeight.bold : FontWeight.normal)));
  Widget _buildAnamnesisNavLabel(String t, {bool isHeader = false}) => Padding(padding: const EdgeInsets.all(16), child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textSecondary)));
  Widget _buildSectionHeader(String t, String u) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), Text(u, style: const TextStyle(color: textSecondary))]);
  Widget _buildPlaceholder(IconData i, String t) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, size: 64, color: borderColor), Text(t)]));
}