import 'package:dart_lcs_client/dart_lcs_client.dart';
import 'dart:io' show Platform;

var env = Platform.environment;
var _lcsUrl = 'REPLACE_WITH_LCS_URL';
var _miscUrl = 'REPLACE_WITH_MISC_URL';

void testHelpResources() async {
  var result = await helpResources(_miscUrl);
  print("************* testHelpResources **********");
  result.forEach((resource) {
    print(resource);
  });
}

void testSitemap() async {
  var result = await sitemap(_miscUrl);
  print("************* testSitemap **********");
  print(result);
}

void testEvents() async {
  var result = await events(_miscUrl);
  print("************* testEvents **********");
  print(result);
}

void testLabelUrl() async {
  var result = await labelUrl(_miscUrl);
  print("************* testLabelUrl **********");
  print(result);
}

void testExpired() {
  print("************* testExpired cred **********");
  var l = LcsCredential("test", "account", DateTime.now());
  assert(l.isExpired());
}

void testLogin() async {
  try {
    await login("bogus", "login", _lcsUrl);
    print("************* failed to catch bad login *************");
  } on LcsLoginFailed catch (e) {
    print("************* caught failed login *************");
  }
  var l = await login(env["LCS_USER"], env["LCS_PASSWORD"], _lcsUrl);
  assert(!l.isExpired());
}

void testPostLcsExpired() async {
  var cred = LcsCredential("Bogus", "Cred", DateTime.now());
  try {
    await postLcs(_lcsUrl,"/read", {}, cred);
    assert(false); // should have thrown CredentialExpired
  } on CredentialExpired catch(e) {
    print(" ************* succesfully caught expired credential *************");
  }
}

void testGetUser() async {
  var cred = await login(env["LCS_USER"], env["LCS_PASSWORD"], _lcsUrl);
  var user = await getUser(_lcsUrl, cred);
  print("************* test get user *************");
  print(user);
}
void testOtherUser() async {
  var cred = await login(env["LCS_USER"], env["LCS_PASSWORD"], _lcsUrl);
  var user = await getUser(_lcsUrl, cred, env["LCS_USER2"]);
  try {
    var baduser = await getUser(_lcsUrl, cred, "fail@email.com");
    assert(false);
  } on NoSuchUser catch(error) {
    print("************* successfuly caught attempt to get nonexistent user *************");
  }
  print("************* test get a different user *************");
  print(user);
}

void testUpdateDayOf() async {
  var cred = await login(env["LCS_USER"], env["LCS_PASSWORD"], _lcsUrl);
  var user = await getUser(_lcsUrl, cred, env["LCS_USER2"]);
  await updateUserDayOf(_lcsUrl, cred, user, "fake_event${DateTime.now().millisecondsSinceEpoch}");
  var user2 = await getUser(_lcsUrl, cred, env["LCS_USER2"]);
  print("************* test update user day_of *************");
  print(user);
  print(user2);
}

void main() async {
  testHelpResources();
  testSitemap();
  testEvents();
  testLabelUrl();
  testExpired();
  testLogin();
  testPostLcsExpired();
  testGetUser();
  testOtherUser();
  testUpdateDayOf();

}
