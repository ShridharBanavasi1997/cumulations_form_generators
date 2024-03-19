class CategoryMasterDataMapper {
  static List<Topics> getDropdownItemByGroupId(int formId) {
    switch (formId) {
      case 2:
        return [
          Topics(1, "Sports"),
          //here, Please maintain T  data type same as you defined data type for the field
          Topics(2, "Politics"),
          Topics(3, "International")
        ];
      //Based on formId you can return the list of options
      default:
        return [];
    }
  }
}

class Topics<T> {
  T id;
  String name;

  Topics(this.id, this.name);
}
