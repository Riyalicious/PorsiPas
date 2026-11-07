class Menu {
  final String nama;
  final String kategori;
  final String imageUrl;
  final double karbohidrat;
  final double protein;
  final double lemak;
  final double porsiGram;

  Menu({
    required this.nama, 
    required this.kategori, 
    required this.imageUrl, 
    required this.karbohidrat, 
    required this.protein, 
    required this.lemak,
    required this.porsiGram,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      nama: json['nama'] ?? json['nama_menu'] ?? 'Menu Tidak Ditemukan',
      kategori: json['kategori'] ?? '-',
      imageUrl: json['image_url'] ?? json['gambar'] ?? json['img'] ?? 'https://via.placeholder.com/150',
      karbohidrat: (json['karbohidrat'] ?? json['karbo'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      lemak: (json['lemak'] ?? 0).toDouble(),
      porsiGram: (json['porsi_gram'] ?? json['porsi'] ?? 100).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'kategori': kategori,
      'image_url': imageUrl,
      'karbohidrat': karbohidrat,
      'protein': protein,
      'lemak': lemak,
      'porsi_gram': porsiGram,
    };
  }
}

class MealPortion {
  final double targetKalori;
  final Menu menu;

  MealPortion({required this.targetKalori, required this.menu});

  factory MealPortion.fromJson(Map<String, dynamic> json) {
    return MealPortion(
      targetKalori: (json['target_kalori'] ?? 0).toDouble(),
      menu: Menu.fromJson(json['menu'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'target_kalori': targetKalori,
      'menu': menu.toJson(),
    };
  }
}

class DietRecommendation {
  final String statusKesehatan;
  final String insightAi;
  final double targetKarboHarian;
  final double targetProteinHarian;
  final double targetLemakHarian;
  final double targetKaloriHarian;
  final double kebutuhanAirMl;
  final int kebutuhanAirGelas;
  final int skorKesehatan;
  final Map<String, MealPortion> porsiMakan;

  DietRecommendation({
    required this.statusKesehatan,
    required this.insightAi,
    required this.targetKarboHarian,
    required this.targetProteinHarian,
    required this.targetLemakHarian,
    required this.targetKaloriHarian,
    required this.kebutuhanAirMl,
    required this.kebutuhanAirGelas,
    required this.skorKesehatan,
    required this.porsiMakan,
  });

  factory DietRecommendation.fromJson(Map<String, dynamic> json) {
    final porsi = json['porsi_makan'] as Map<String, dynamic>? ?? {};
    return DietRecommendation(
      statusKesehatan: json['status_kesehatan'] ?? 'Tidak Diketahui',
      insightAi: json['insight_ai'] ?? '',
      targetKarboHarian: (json['target_karbo_harian'] ?? 0).toDouble(),
      targetProteinHarian: (json['target_protein_harian'] ?? 0).toDouble(),
      targetLemakHarian: (json['target_lemak_harian'] ?? 0).toDouble(),
      targetKaloriHarian: (json['target_kalori_harian'] ?? 0).toDouble(),
      kebutuhanAirMl: (json['kebutuhan_air_ml'] ?? 0).toDouble(),
      kebutuhanAirGelas: json['kebutuhan_air_gelas'] ?? 0,
      skorKesehatan: json['skor_kesehatan'] ?? 0,
      porsiMakan: {
        "sarapan": MealPortion.fromJson(porsi['sarapan'] as Map<String, dynamic>? ?? {}),
        "makan_siang": MealPortion.fromJson(porsi['makan_siang'] as Map<String, dynamic>? ?? {}),
        "makan_malam": MealPortion.fromJson(porsi['makan_malam'] as Map<String, dynamic>? ?? {}),
      },
    );
  }
}