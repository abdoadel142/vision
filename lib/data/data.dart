class SliderModel {
  String imageAssetPath;
  String title;
  String desc;

  SliderModel({this.imageAssetPath, this.title, this.desc});

  void setImageAssetPath(String getImageAssetPath) {
    imageAssetPath = getImageAssetPath;
  }

  void setTitle(String getTitle) {
    title = getTitle;
  }

  void setDesc(String getDesc) {
    desc = getDesc;
  }

  String getImageAssetPath() {
    return imageAssetPath;
  }

  String getTitle() {
    return title;
  }

  String getDesc() {
    return desc;
  }
}

List<SliderModel> getSlides() {
  List<SliderModel> slides = new List<SliderModel>();
  SliderModel sliderModel = new SliderModel();

  sliderModel.setDesc("We will help you to read any text.");
  sliderModel.setTitle("Reading");
  sliderModel.setImageAssetPath("assets/1.png");
  slides.add(sliderModel);

  sliderModel = new SliderModel();

  sliderModel.setDesc(
      "We will answer all your questions to know the things around you.");
  sliderModel.setTitle("Asking");
  sliderModel.setImageAssetPath("assets/2.png");
  slides.add(sliderModel);

  sliderModel = new SliderModel();

  sliderModel.setDesc(
      "We will help you to know the way around you so that you can know your way.");
  sliderModel.setTitle("PLace");
  sliderModel.setImageAssetPath("assets/3.png");
  slides.add(sliderModel);

  sliderModel = new SliderModel();

  return slides;
}
