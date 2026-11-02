class DietRequest {
  final int umur;
  final double tinggi;
  final double berat;
  final int frekuensiOlahraga;
  final String jenisKelamin;
  final String targetTubuh;

  DietRequest({
    required this.umur,
    required this.tinggi,
    required this.berat,
    required this.frekuensiOlahraga,
    required this.jenisKelamin,
    required this.targetTubuh,
  });

  Map<String, dynamic> toJson() {
    return {
      'umur': umur,
      'tinggi': tinggi,
      'berat': berat,
      'frekuensi_olahraga': frekuensiOlahraga,
      'jenis_kelamin': jenisKelamin,
      'target_tubuh': targetTubuh,
    };
  }
}

class MealDetail {
  final String menu;
  final double kalori;
  final double proteinG;
  final double lemakG;
  final double karboG;
  final String gambarUrl;

  MealDetail({
    required this.menu,
    required this.kalori,
    required this.proteinG,
    required this.lemakG,
    required this.karboG,
    required this.gambarUrl,
  });

factory MealDetail.fromJson(Map<String, dynamic> json) {
    return MealDetail(
      menu: json['menu'] ?? '',
      kalori: (json['kalori'] as num?)?.toDouble() ?? 0.0,
      proteinG: (json['protein_g'] as num?)?.toDouble() ?? 0.0,
      lemakG: (json['lemak_g'] as num?)?.toDouble() ?? 0.0,
      karboG: (json['karbo_g'] as num?)?.toDouble() ?? 0.0,
      gambarUrl: json['image_url'] ?? '', // <-- UBAH BAGIAN INI MENJADI image_url
    );
  }
}

class MealPlanResponse {
  final MealDetail sarapan;
  final MealDetail makanSiang;
  final MealDetail makanMalam;

  MealPlanResponse({
    required this.sarapan,
    required this.makanSiang,
    required this.makanMalam,
  });

  factory MealPlanResponse.fromJson(Map<String, dynamic> json) {
    return MealPlanResponse(
      sarapan: MealDetail.fromJson(json['sarapan'] ?? {}),
      makanSiang: MealDetail.fromJson(json['makan_siang'] ?? {}),
      makanMalam: MealDetail.fromJson(json['makan_malam'] ?? {}),
    );
  }
}

class MacroNutrients {
  final double karboPersen;
  final double proteinPersen;
  final double lemakPersen;

  MacroNutrients({
    required this.karboPersen,
    required this.proteinPersen,
    required this.lemakPersen,
  });

  factory MacroNutrients.fromJson(Map<String, dynamic> json) {
    return MacroNutrients(
      karboPersen: (json['karbo_persen'] as num?)?.toDouble() ?? 0.50,
      proteinPersen: (json['protein_persen'] as num?)?.toDouble() ?? 0.25,
      lemakPersen: (json['lemak_persen'] as num?)?.toDouble() ?? 0.25,
    );
  }
}

class DietResponse {
  final String kategoriDiet;
  final double bmr;
  final double kaloriHarian;
  final double beratIdeal;
  final MealPlanResponse rekomendasiMakanan;
  final MacroNutrients makronutrisi;

  DietResponse({
    required this.kategoriDiet,
    required this.bmr,
    required this.kaloriHarian,
    required this.beratIdeal,
    required this.rekomendasiMakanan,
    required this.makronutrisi,
  });

  factory DietResponse.fromJson(Map<String, dynamic> json) {
    return DietResponse(
      kategoriDiet: json['kategori_diet'] ?? '',
      bmr: (json['bmr'] as num?)?.toDouble() ?? 0.0,
      kaloriHarian: (json['kalori_harian'] as num?)?.toDouble() ?? 0.0,
      beratIdeal: (json['berat_ideal'] as num?)?.toDouble() ?? 0.0,
      rekomendasiMakanan: MealPlanResponse.fromJson(json['rekomendasi_makanan'] ?? {}),
      makronutrisi: MacroNutrients.fromJson(json['makronutrisi'] ?? {}),
    );
  }
}