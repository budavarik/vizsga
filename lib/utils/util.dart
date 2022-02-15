class Util  {

  String normalizeTimeMin(int min) {
    String retVal = "";
    min < 10 ? retVal = "0" + min.toString() : retVal = min.toString();
    return retVal;
  }


}