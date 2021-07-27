class TestData {
  List<Categories> categories;

  TestData({this.categories});

  TestData.fromJson(Map<String, dynamic> json) {
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories.add(new Categories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.categories != null) {
      data['categories'] = this.categories.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Categories {
  String name;
  List<Videos> videos;

  Categories({this.name, this.videos});

  Categories.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    if (json['videos'] != null) {
      videos = new List<Videos>();
      json['videos'].forEach((v) {
        videos.add(new Videos.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    if (this.videos != null) {
      data['videos'] = this.videos.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Videos {
  String description;
  List<String> sources;
  String subtitle;
  String thumb;
  String title;

  Videos(
      {this.description, this.sources, this.subtitle, this.thumb, this.title});

  Videos.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    sources = json['sources'].cast<String>();
    subtitle = json['subtitle'];
    thumb = json['thumb'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['sources'] = this.sources;
    data['subtitle'] = this.subtitle;
    data['thumb'] = this.thumb;
    data['title'] = this.title;
    return data;
  }
}
