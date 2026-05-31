import 'package:flutter/material.dart';
import 'package:mobile_app/theme/app_colors.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<Map<String, String>> _faqs = [
    {
      'category': 'Booking',
      'question': 'Bagaimana cara melakukan booking ruang?',
      'answer':
          'Buka menu booking, pilih kampus terlebih dahulu, lalu pilih ruangan yang tersedia. Setelah tanggal dipilih, sistem hanya menampilkan jam yang kosong. Booking akan otomatis disetujui jika slot masih tersedia.',
    },
    {
      'category': 'Booking',
      'question': 'Jam berapa booking boleh dilakukan?',
      'answer':
          'Booking hanya dapat dibuat pada rentang jam 07:00 sampai 17:00. Di luar jam tersebut, sistem akan menolak pengajuan booking.',
    },
    {
      'category': 'Booking',
      'question': 'Bagaimana jika saya ingin membatalkan booking?',
      'answer':
          'Pembatalan booking hanya bisa dilakukan maksimal H-2 dari tanggal booking. Jika sudah melewati batas tersebut, tombol batal akan tetap muncul tetapi sistem akan menolak proses pembatalan.',
    },
    {
      'category': 'Booking',
      'question': 'Bisakah saya mengubah tanggal dan waktu booking?',
      'answer':
          'Saat ini fitur ubah jadwal belum tersedia. Jika ada perubahan, silakan batalkan booking sesuai aturan H-2 lalu buat booking baru dengan jadwal yang benar.',
    },
    {
      'category': 'Notifikasi',
      'question': 'Kapan saya menerima notifikasi booking?',
      'answer':
          'Setelah booking berhasil, Anda akan menerima notifikasi otomatis dari sistem. Untuk jadwal kelas, sistem juga dapat mengirim pengingat 30 menit sebelum waktu mulai.',
    },
    {
      'category': 'Notifikasi',
      'question': 'Apakah notifikasi bisa dikirim oleh admin?',
      'answer':
          'Ya. Admin dapat mengirim notifikasi manual untuk keperluan umum, pengumuman, atau informasi penting lainnya. Notifikasi akan diberi penanda sumber admin atau sistem.',
    },
    {
      'category': 'Akun',
      'question': 'Bagaimana cara mengatur notifikasi booking?',
      'answer':
          'Anda dapat mengatur notifikasi melalui menu "Pengaturan Notifikasi" di halaman Profil. Di sana Anda dapat mengaktifkan atau menonaktifkan berbagai jenis notifikasi termasuk pengingat booking.',
    },
    {
      'category': 'Ruang',
      'question': 'Ruang apa saja yang tersedia di aplikasi ini?',
      'answer':
          'Aplikasi menyediakan beberapa jenis ruang seperti kelas, ruang meeting, dan lab komputer. Daftar ruang menyesuaikan data kampus yang tersedia dan jadwal yang belum terpakai.',
    },
  ];

  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final categories = _faqs.map((item) => item['category']!).toSet().toList();

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
          color: AppColors.textPrimary,
        ),
        title: Text(
          'FAQ (Pertanyaan Umum)',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: isMobile ? 46 : 52,
                      height: isMobile ? 46 : 52,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.help_outline_rounded,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(width: isMobile ? 12 : 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FAQ Ruangin',
                            style: TextStyle(
                              fontSize: isMobile ? 18 : 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.white,
                            ),
                          ),
                          SizedBox(height: isMobile ? 4 : 6),
                          Text(
                            'Jawaban singkat tentang aturan booking, pembatalan, notifikasi, dan penggunaan aplikasi.',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 13,
                              color: AppColors.white.withValues(alpha: 0.9),
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? 14 : 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories
                    .map(
                      (category) => Chip(
                        label: Text(category),
                        labelStyle: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                        backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: isMobile ? 18 : 22),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _faqs.length,
                itemBuilder: (context, index) {
                  final faq = _faqs[index];
                  final isExpanded = _expandedIndex == index;

                  return Container(
                    margin: EdgeInsets.only(
                      bottom: isMobile ? 10 : 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isExpanded
                            ? AppColors.primary
                            : AppColors.borderLight,
                        width: isExpanded ? 1.5 : 1,
                      ),
                      boxShadow: isExpanded
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _expandedIndex = isExpanded ? null : index;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: EdgeInsets.all(isMobile ? 14 : 16),
                            child: Row(
                              children: [
                                  Container(
                                    width: isMobile ? 28 : 30,
                                    height: isMobile ? 28 : 30,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _getCategoryIcon(faq['category']!),
                                      color: AppColors.primary,
                                      size: isMobile ? 16 : 18,
                                    ),
                                  ),
                                  SizedBox(width: isMobile ? 10 : 12),
                                Expanded(
                                  child: Text(
                                    faq['question']!,
                                    style: TextStyle(
                                      fontSize: isMobile ? 12 : 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                SizedBox(width: isMobile ? 8 : 12),
                                Icon(
                                  isExpanded
                                      ? Icons.expand_less_rounded
                                      : Icons.expand_more_rounded,
                                  color: AppColors.primary,
                                  size: isMobile ? 20 : 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isExpanded) ...[
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.borderLight,
                          ),
                          Padding(
                            padding: EdgeInsets.all(isMobile ? 14 : 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  faq['category']!,
                                  style: TextStyle(
                                    fontSize: isMobile ? 10 : 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(height: isMobile ? 8 : 10),
                                Container(
                                  padding: EdgeInsets.all(isMobile ? 10 : 12),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.primary.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    faq['answer']!,
                                    style: TextStyle(
                                      fontSize: isMobile ? 11 : 12,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: isMobile ? 20 : 24),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 14 : 16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                      size: isMobile ? 20 : 24,
                    ),
                    SizedBox(width: isMobile ? 10 : 12),
                    Expanded(
                      child: Text(
                        'Tidak menemukan jawaban? Hubungi admin melalui menu bantuan atau notifikasi manual dari sistem.',
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? 16 : 20),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Booking':
        return Icons.meeting_room_rounded;
      case 'Notifikasi':
        return Icons.notifications_rounded;
      case 'Akun':
        return Icons.person_rounded;
      case 'Ruang':
        return Icons.domain_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}
