import 'dart:convert';
import 'dart:html' as html;
import 'dart:io' as io;
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'dart:js' as js;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:fluwx/fluwx.dart';
// import 'package:tencent_kit/tencent_kit.dart';
import 'package:oktoast/oktoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void shareAction() {
  // 在此处执行与Android原生应用的通信
  // js.context.callMethod();
  print('Calling Android App with message: ');

  // TencentKitPlatform.instance.shareWebpage(
  //   scene: TencentScene.kScene_QQ,
  //   title: '愉聊,有你真好',
  //   summary: "你想要的,这都有~",
  //   imageUri: Uri.parse("lib/logo.png"),
  //   targetUrl: shareModel.url,
  //
  // );
}

void main() async {

  await DataManager.getInstance();

  js.context['shareAction'] = js.allowInterop(shareAction);

  // await TencentKitPlatform.instance.setIsPermissionGranted(granted: true);
  //
  // await TencentKitPlatform.instance.registerApp(appId:"102063149", universalLink: 'https://appapi.ismyapp.shop/qq_conn/102063149');
  //
  // await Fluwx().registerApi(appId: "wx3d2d20d4b4f2fc47", universalLink: "https://ismyapp.com/share_wechat/wx3d2d20d4b4f2fc47/");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
      textStyle:const TextStyle(
          color: Color(0xffffffff),
          fontSize: 19
      ),
      position: ToastPosition.center,
      textPadding:const EdgeInsets.all(15),
      backgroundColor: Colors.black,
      radius: 10.0,
      animationCurve: Curves.easeIn,
      animationDuration:const Duration(milliseconds: 200),
      duration:const Duration(seconds: 3),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(

          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: '邀请好友'),
      ),
    );
  }
}

const RELEASE_API = "https://appapi.ismyapp.shop/api/v1/";
const DEBUG_API = "https://appapi.ismyapp.shop/debug/api/v1/";
const INVITE_LIST_CELL_HEIGHT = 80.0;
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late double _totalIncome = 0.0;
  late int _totalInvite = 0;
  late double _weekIncome = 0.0;
  late int _weekInvite = 0;
  late double _todayIncome = 0.0;
  late int _todayInvite = 0;

  late int _canBind = 0;

  late String _inviteCode = "";

  final TextEditingController _checkController = TextEditingController();
  final FocusNode _checkFocus = FocusNode();
  final TextEditingController _bindController = TextEditingController();
  final FocusNode _bindFocus = FocusNode();

  late String _token;
  late bool _isDebug = false;

  late List <InviteListData> _inviteList = [];

  late String _apiPath = RELEASE_API;

  late int _currentPage = 1;

  late bool _needShowMore = false;

  late bool _isCheckSingle = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    _isDebug = _getIsDebug();

    if (_isDebug) {
      _apiPath = DEBUG_API;
    } else {
      _apiPath = RELEASE_API;
    }

    _token = _getTokenFromUrl();

    print("======$_token===$_isDebug==$_apiPath");

    //
    _getBaseInfo();

    _getInviteCode();

    _getMyInviteList();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Colors.white,

        title:  Text(
            widget.title,
          style:const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600
          ),
        ),
      ),
      body: Stack(
        alignment: Alignment.centerRight,
        children: [
          SingleChildScrollView(
            child: Container(
              color:const Color(0xffFA6E71),
              child: Column(
                children: [
                  const SizedBox(height: 20,),
                  Image.asset(
                    "lib/header.png",
                    fit: BoxFit.fitHeight,
                    height: 200,
                  ),
                  _canBind == 1 ? Column(

                    children: [
                      const SizedBox(height: 20,),
                      Container(
                        padding:const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        margin: const EdgeInsets.symmetric(horizontal: 15),

                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              width: 7,
                              color:const Color(0x66FA6E71),
                            )
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                           const Text(
                              "我是被邀请用户,想与邀请人建立绑定关系:",
                              style: TextStyle(
                                  color:  Color(0xffFA6E71),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400
                              ),
                            ),
                            const SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child:  Container(
                                    padding:const EdgeInsets.symmetric(horizontal: 15, vertical: 12),

                                    decoration:  BoxDecoration(
                                        color:const Color(0x99dddddd),
                                        borderRadius: BorderRadius.circular(100)
                                    ),
                                    child:TextField(
                                      maxLines: 1,
                                      focusNode: _bindFocus,
                                      controller: _bindController,
                                      style:const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black
                                      ),
                                      decoration:const InputDecoration(
                                          isCollapsed:true,
                                        // counterText: "",
                                          border: InputBorder.none,
                                          hintStyle:  TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey
                                          ),
                                          hintText: '输入邀请码,与邀请人建立绑定关系'
                                      ),

                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                GestureDetector(
                                  onTap: () {
                                    if (kDebugMode) {
                                      print("bangdingguanxi");
                                    }

                                    _bindInviteCode();

                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    height: 35,
                                    decoration: BoxDecoration(
                                        color: const Color(0x33FA6E71),
                                        borderRadius: BorderRadius.circular(100)
                                    ),
                                    child:const Text(
                                      "立即绑定",
                                      style: TextStyle(
                                          color:  Color(0xffFA6E71),
                                          fontWeight: FontWeight.w600
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ) : const SizedBox.shrink(),
                  const SizedBox(height: 20,),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          width: 7,
                          color:const Color(0x66FA6E71),
                        )
                    ),
                    child: Column(
                      children: [

                        Container(
                          width: double.infinity,

                          padding:const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: const Color(0x11FA6E71),
                            border: Border.all(
                              width: 3,
                              color:const Color(0xffFA6E71),
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "我的邀请码",
                                style: TextStyle(
                                    fontSize: 15,
                                    color:  Color(0xff333333),
                                    fontWeight: FontWeight.w600
                                ),
                              ),
                              const SizedBox(height: 15,),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: _inviteCode));
                                  showToast("邀请码复制成功");
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0x11FA6E71),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    _inviteCode,
                                    style:const TextStyle(
                                        fontSize: 30,
                                        color:  Color(0xffFA6E71),
                                        fontWeight: FontWeight.w600
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10,),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: _inviteCode));
                                  showToast("邀请码复制成功");
                                },
                                child: const Text(
                                  "点击复制",
                                  style: TextStyle(
                                      fontSize: 11,
                                      color:  Color(0xff333333),
                                      fontWeight: FontWeight.normal
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10,),
                              GestureDetector(
                                onTap: () {

                                  // js.JsFunction.shareAction();



                                  shareAction();

                                  // js.JsFunction.withThis(shareAction);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  width: 180,
                                  decoration: BoxDecoration(
                                      color: const Color(0xffFA6E71),
                                      borderRadius: BorderRadius.circular(100)
                                  ),
                                  child:const Text(
                                    "邀请好友",
                                    style: TextStyle(
                                        color:  Color(0xffffffff),
                                        fontWeight: FontWeight.w600
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 10,),
                        const Text.rich(
                            TextSpan(
                                text: "奖励1:好友",
                                style: TextStyle(
                                    color: Color(0xff333333),
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal
                                ),
                                children: [
                                  TextSpan(
                                    text: "每笔充值",
                                    style: TextStyle(
                                        color: Color(0xffFA6E71),
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal
                                    ),

                                  ),
                                  TextSpan(
                                    text: ",你就能拿",
                                    style: TextStyle(
                                        color: Color(0xff333333),
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal
                                    ),

                                  ),
                                  TextSpan(
                                    text: "10%",
                                    style: TextStyle(
                                        color: Color(0xffFA6E71),
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal
                                    ),
                                  ),
                                  TextSpan(
                                    text: "分成",
                                    style: TextStyle(
                                        color: Color(0xff333333),
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal
                                    ),

                                  ),
                                ]
                            )
                        ),
                        const SizedBox(height: 5,),
                        const Text.rich(
                            TextSpan(
                                text: "奖励2:好友",
                                style: TextStyle(
                                    color: Color(0xff333333),
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal
                                ),
                                children: [
                                  TextSpan(
                                    text: "赚钱收益",
                                    style: TextStyle(
                                        color: Color(0xffFA6E71),
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal
                                    ),

                                  ),
                                  TextSpan(
                                    text: ",你就能拿",
                                    style: TextStyle(
                                        color: Color(0xff333333),
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal
                                    ),

                                  ),
                                  TextSpan(
                                    text: "10%",
                                    style: TextStyle(
                                        color: Color(0xffFA6E71),
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal
                                    ),
                                  ),
                                  TextSpan(
                                    text: "分成",
                                    style: TextStyle(
                                        color: Color(0xff333333),
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal
                                    ),

                                  ),
                                ]
                            )
                        ),
                        const SizedBox(height: 5,),
                        const Text(
                          "PS:有效期3年,赚钱赚到手软",
                          style: TextStyle(
                              color: Color(0xffaaaaaa),
                              fontSize: 10,
                              fontWeight: FontWeight.normal
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          width: 7,
                          color:const Color(0x66FA6E71),
                        )
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10,),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          height: 150,
                          decoration: BoxDecoration(
                            color: const Color(0x11FA6E71),
                            border: Border.all(
                              width: 3,
                              color:const Color(0xffFA6E71),
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                  child: Row(
                                    children: [
                                      _dataCard(_totalIncome.toStringAsFixed(2), "总收益金额(元)"),
                                      _dataCard(_weekIncome.toStringAsFixed(2), "本周累计收益(元)"),
                                      _dataCard(_todayIncome.toStringAsFixed(2), "今日获得收益(元)")
                                    ],
                                  )
                              ),
                              Expanded(
                                  child: Row(
                                    children: [
                                      _dataCard(_totalInvite.toString(), "总邀请人数"),
                                      _dataCard(_weekInvite.toString(), "本周邀请人数"),
                                      _dataCard(_todayInvite.toString(), "今日邀请人数")
                                    ],
                                  )
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Container(
                          padding:const EdgeInsets.symmetric(horizontal: 50),
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child:  Container(
                                  padding:const EdgeInsets.symmetric(horizontal: 15, vertical: 12),

                                  decoration:  BoxDecoration(
                                      color:const Color(0x99dddddd),
                                      borderRadius: BorderRadius.circular(100)
                                  ),
                                  child:TextField(
                                    maxLines: 1,
                                    focusNode: _checkFocus,
                                    controller: _checkController,
                                    style:const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black
                                    ),
                                    decoration:const InputDecoration(
                                        isCollapsed:true,
                                      // counterText: "",
                                        border: InputBorder.none,
                                        hintStyle:  TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey
                                        ),
                                        hintText: '输入ID查询已绑定用户'
                                    ),

                                  ),
                                ),
                              ),
                              const SizedBox(width: 10,),
                              GestureDetector(
                                onTap: () {
                                  if (kDebugMode) {
                                    print("查询");
                                  }

                                  if (_checkController.text.isEmpty && _isCheckSingle == false) {
                                    return;
                                  }
                                  _currentPage = 1;
                                  _isCheckSingle = true;
                                  _getMyInviteList();

                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  width: 80,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: const Color(0x33FA6E71),
                                      borderRadius: BorderRadius.circular(100)
                                  ),
                                  child:const Text(
                                    "查询",
                                    style: TextStyle(
                                        color:  Color(0xffFA6E71),
                                        fontWeight: FontWeight.w600
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 10,),
                        SizedBox(
                          height: max(_inviteList.length * INVITE_LIST_CELL_HEIGHT, 400),
                          child: ListView.builder(
                              itemCount: _inviteList.length,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              primary:false,
                              itemBuilder: (context, index) {
                                InviteListData data = _inviteList[index];
                                return Container(
                                  padding:const EdgeInsets.symmetric(horizontal: 20,),
                                  height: INVITE_LIST_CELL_HEIGHT,
                                  child: Row(

                                    children: [

                                      ImageView(
                                        data.headImg,
                                        width: 60,
                                        height: 60,
                                        radius: 40,
                                      ),
                                      const SizedBox(width: 10,),
                                      Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                children: [

                                                  Expanded(
                                                      child: Text(
                                                        data.nickName,
                                                        style: const TextStyle(
                                                          color: Color(0xff333333),
                                                          fontSize: 15,
                                                        ),
                                                      )
                                                  ),
                                                  Text(
                                                    data.inviteTime,
                                                    style: const TextStyle(
                                                      color: Color(0xff333333),
                                                      fontSize: 14,
                                                    ),
                                                  )

                                                ],
                                              ),
                                              const SizedBox(height: 5,),
                                              Row(
                                                children: [

                                                  Expanded(
                                                      child: Text(
                                                        "用户ID:${data.lailiaoNum}",
                                                        style: const TextStyle(
                                                          color: Color(0xff333333),
                                                          fontSize: 12,
                                                        ),
                                                      )
                                                  ),
                                                  Text(
                                                    "累计产生收益(元):${data.profitAmt}",
                                                    style: const TextStyle(
                                                      color: Color(0xff333333),
                                                      fontSize: 12,
                                                    ),
                                                  )

                                                ],
                                              )
                                            ],
                                          )
                                      ),

                                    ],
                                  ),
                                );
                              }
                          ),
                        ),
                        const SizedBox(height: 10,),
                        _needShowMore ?  Column(
                          children: [
                            GestureDetector(
                              onTap:() {

                                _currentPage++;
                                _getMyInviteList();

                              },
                              child:const SizedBox(
                                height:20,
                                width: 100,
                                child: Text(
                                  "下一页",
                                  style: TextStyle(
                                      color:  Color(0xff333333),
                                      fontWeight: FontWeight.normal,
                                    fontSize: 14
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10,),
                          ],
                        ) : const SizedBox.shrink(),

                        Container(
                          padding:const EdgeInsets.symmetric(horizontal: 30),
                          height: 40,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (kDebugMode) {
                                      print("导出昨日数据");
                                    }
                                    _exportData(2);
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: const Color(0xffFA6E71),
                                        borderRadius: BorderRadius.circular(100)
                                    ),
                                    child:const Text(
                                      "导出昨日数据",
                                      style: TextStyle(
                                          color:  Color(0xffffffff),
                                          fontWeight: FontWeight.w600
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20,),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (kDebugMode) {
                                      print("导出上周数据");
                                    }
                                    _exportData(1);
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: const Color(0xffFA6E71),
                                        borderRadius: BorderRadius.circular(100)
                                    ),
                                    child:const Text(
                                      "导出上周数据",
                                      style: TextStyle(
                                          color:  Color(0xffffffff),
                                          fontWeight: FontWeight.w600
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 10,),
                      ],
                    ),
                  ),
                  const Padding(
                    padding:  EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "本活动最终解释权归平台所有",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,

                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
              right: 0,
              height: 100,
              width: 45,
              child: GestureDetector(
                onTap: () {
                  if (kDebugMode) {
                    print("活动规则");
                  }

                  ActivityRuleAlert.show(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                 decoration: BoxDecoration(
                   color: const Color(0xffFF9B9B),
                   borderRadius:const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                   border: Border.all(
                     width: 3,
                     color:const Color(0xffFA6E71),
                   )
                 ),
                  child: const Row(
                    children: [
                      Text(
                        "活\n动\n规\n则",
                        style: TextStyle(
                          color: Colors.white
                        ),
                      )
                    ],
                  ),
                ),
              ),


          )
        ],
      ),
    );
  }

  _dataCard([String title = "", String subtitle = ""]) {

    return Expanded(
        child: Container(
          padding:const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: Center(
                    child: Text(
                      title,
                      style:const TextStyle(
                        color:  Color(0xffFA6E71),
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  )
              ),
              Expanded(
                  child: Center(
                    child: Text(
                      subtitle,
                      style:const TextStyle(
                        color:  Color(0xff333333),
                      ),
                    ),
                  )
              ),
            ],
          ),
        )
    );
  }


  String _getTokenFromUrl() {
    String? search = html.window.location.search;

    print("=====$search");
    if (search!.startsWith('?')) {
      search = search.substring(1);
    }
    for (var part in search.split('&')) {
      var split = part.split('=');
      if (split.length == 2 && split[0] == 'token') {
        return split[1];
      }
    }
    return "";
  }

  bool _getIsDebug() {
    String? search = html.window.location.search;


    if (search!.startsWith('?')) {
      search = search.substring(1);
    }
    for (var part in search.split('&')) {
      print("part=====$part");
      var split = part.split('=');
      if (split.length == 2 && split[0].toLowerCase() == 'isdebug') {
        return split[1] == "1";
      }
    }
    return false;
  }

  _getBaseInfo () async {


    ResultModel model = await ApiUtils.requestApi(context, _apiPath, "invite/qryUserInviteCount", _token);

    print("_getBaseInfo===${model.result!["data"]}");

    if (model.result!["data"] is Map) {

      Map<String, dynamic> result = model.result!["data"];

      print("_getBaseInf222o===$result");

      _totalIncome = result["allProfitAmt"] ?? 0.0;
      _totalInvite = result["allInviteNum"] ?? 0;
      _weekIncome = result["weekProfitAmt"] ?? 0.0;
      _weekInvite = result["weekInviteNum"] ?? 0;
      _todayIncome = result["todayProfitAmt"] ?? 0.0;
      _todayInvite = result["todayInviteNum"] ?? 0;

      _canBind = result["canBind"] ?? 0;
      if (mounted){
        setState(() {

        });
      }
      print("_getBaseInf3333===$result");
    }

  }

  _getInviteCode() async {
    ResultModel model = await ApiUtils.requestApi(context, _apiPath, "invite/qryMyInvite", _token);

    print("_getInviteCode===${model.result!["data"]}");

    if (model.result!["data"] is Map) {

      Map<String, dynamic> result = model.result!["data"];

      print("_getInviteCode===$result");

      _inviteCode = result["inviteCode"]?.toString() ?? "";

      if (mounted){
        setState(() {

        });
      }
      print("_getInviteCode===$result");
    }
  }

  _bindInviteCode() async {

    if (_bindController.text.isEmpty) {
      FocusScope.of(context).requestFocus(_bindFocus);
      return;
    }

    if (_bindController.text == _inviteCode) {
      showToast("不能填写自己的邀请码");
      _bindController.text = "";
      return;
    }

    ResultModel model = await ApiUtils.requestApi(context, _apiPath, "invite/handBindParent", _token, params: {'inviteCode':_bindController.text}, needShowHud: true);

    print("_getInviteCode===${model.result!["data"]}");

    if (model.code == "200") {

      showToast("绑定成功");

     _canBind = 0;

      if (mounted){
        setState(() {

        });
      }
    }
  }

  _getMyInviteList() async {



    Map<String, dynamic> params = {};
    params["size"] = "20";
    if (_checkController.text.isNotEmpty) {
      params["lailiaoNum"] =  _checkController.text;
    }
    params["current"] = _currentPage;

    ResultModel model = await ApiUtils.requestApi(context, _apiPath, "invite/qryMyInviteNew", _token, params: params);

    if (model.result!["data"] is Map) {

      Map<String, dynamic> result = model.result!["data"];

      int pages = result["pages"] ?? 0;
      int current = result["current"] ?? 0;
      List record = result["record"];

      if (_checkController.text.isNotEmpty) {
        if (record.isEmpty) {
          showToast("未与该用户行成绑定关系,请核对ID后重试");
          _checkController.text = "";
          _isCheckSingle = false;
          return;
        }
      }

      _needShowMore = pages > current;

      List<InviteListData> inviteList = [...(result["record"] as List ?? []).map((o) => InviteListData.fromJson(o))];

      if(_currentPage == 1) {
        _inviteList.clear();
      }
      _inviteList.addAll(inviteList);

      if (mounted) {
        setState(() {

        });
      }

      print("_getMyInviteList====$pages===$current= -=== $record=======$inviteList=");
    }

    if (_checkController.text.isNotEmpty) {
      _checkController.text = "";
    }
  }

  _exportData(int type) async {

    Map<String, dynamic> params = {};
    params['type'] = type;

    ResultModel model = await ApiUtils.requestApi(context, _apiPath, "invite/exportInviteData", _token, params: params, method: getType);


  }
  
}





class ActivityRuleAlert {

  static show(BuildContext context) {

    showDialog(
        barrierDismissible : false,
        context: context,
        builder: (context) {

          return StatefulBuilder(
            builder: (context,setState ) {
              return Center(
                child: Material(
                  type: MaterialType.transparency,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      FocusScope.of(context).unfocus();
                    },
                    child:const ActivityRulePage(),
                  ),
                ),
              );
            },
          );
        }
    );
  }
}

class ActivityRulePage extends StatefulWidget {
  const ActivityRulePage({Key? key}) : super(key: key);

  @override
  State<ActivityRulePage> createState() => _ActivityRulePageState();
}

class _ActivityRulePageState extends State<ActivityRulePage> {


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          // color: Colors.red,
          padding:const EdgeInsets.only(top: 20, bottom: 60),
          child: Container(
            padding:const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            margin:const EdgeInsets.symmetric(horizontal: 50),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child:const Text(
              "1.将自己的邀请码发送给好友，好友在注册时填写，则可与你形成绑定关系"
                  "\n\n2.绑定后，好友的每次充值，你都能获得10%的分成； 好友收礼物获得的收益（打招呼除外），你也能获得10%的分成"
                  "\n\n3.分成收益可以直接提现"
                  "\n\n4.只有成功邀请的前50名好友的充值/收益行为可以给 你带来分成收益；后续邀请的好友将不会给你带来分成收益"
                  "\n\n5.例，若好友充值10000元，则可得分成1000元；若好友收益10000积分，则可得分成1000积分",
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ),
        ),
        Image.asset(
          "lib/title_img.png",
          fit: BoxFit.fitHeight,
          height: 40,
        ),
        Positioned(
          bottom: 0,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Image.asset(
              "lib/close.png",
              fit: BoxFit.fitHeight,
              color: Colors.grey,
              height: 40,
            ),
          ),
        ),
      ],
    );
  }

}


const String getType = 'get';
const String postType = 'post';
const String deleteType = 'delete';

class ApiUtils {

  static Future<ResultModel> requestApi (final BuildContext context, String baseUrl,String api, String token, {Map<String, dynamic>? params, bool needShowHud = false, String hudString = "", String method = postType, bool needToast = true}) async {

    final BuildContext newContext = context;

    if ( needShowHud || hudString.isNotEmpty) {
      LoadingHud.showHud(newContext, toast: hudString);
    }


    Response? response = await ApiUtils(baseUrl: baseUrl, token: token).request(api, data:params,method: method);

    print("Response? response = ======$response");
    if (needShowHud || hudString.isNotEmpty) {
      LoadingHud.dismissHud(newContext);
    }

    if (response!.statusCode != 200) {
      return ResultModel(code: "0");
    }
    ResultModel? result = ResultModel.fromMap(json.decode(response.data));

    String code = result.code;
    String msg = result.message;
    print("ResultModel======$code=====$msg");
    if (code == "200") {
      return result;
    } else if (code == "401") {///登录过期

      if (needToast == false) {
        // showToast(msg);

        return result;
      } else {
        showToast(msg);

        return result;
      }
    } else {
      if (needToast == false) {
        return result;
      } else {
        showToast(msg);
      }
      return result;
    }

  }




  Dio? _dio;

  CancelToken? cancelToken = CancelToken();

  Dio get dio => _dio!;

  Map<String, dynamic> headers = {"Content-Type": "application/json"};

  ApiUtils({String baseUrl = RELEASE_API, String token = ""}) {
    print('dio赋值=====$baseUrl');

    /// 或者通过传递一个 `options`来创建dio实例
    BaseOptions options = BaseOptions(
      /// 请求基地址,可以包含子路径，如: "https://www.google.com/api/".
      baseUrl: baseUrl,

      /// 连接服务器超时时间，单位是毫秒.
      connectTimeout:const Duration(milliseconds: 15000),

      /// 接收数据的总时限.
      receiveTimeout: const Duration(milliseconds: 15000),

      /// [表示期望以那种格式(方式)接受响应数据。接受四种类型 `json`, `stream`, `plain`, `bytes`. 默认值是 `json`](https://github.com/flutterchina/dio/issues/30)
      responseType: ResponseType.plain,

      /// Http请求头.
      headers: headers,


      // headers: {
      //   Http.cookieHeader: getCookieString(),
      // }

    );

    _dio = Dio(options);
    //
    // (_dio?.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
    //   client.findProxy = (uri) {
    //     //proxy all request to localhost:8888
    //     return "PROXY 192.168.1.23:8888"; //这里将localhost设置为自己电脑的IP，其他不变，注意上线的时候一定记得把代理去掉
    //   };
    // };

    /// 添加拦截器
    _dio!.interceptors
      ..add(InterceptorsWrapper(
        /// 请求时的处理
        onRequest: (RequestOptions options, handler) {

          print("\n================== 请求数据 ==========================");
          print("url = ${options.uri.toString()}");
          print("data = ${options.data}");
          print("queryParameters = ${options.queryParameters}");
          print("method = ${options.method}");

          print("headers =11111");

          Map<String, dynamic> header = {};
          print("headers =222222");
          if (kIsWeb) {
            header["source_type"] = "1";
            header["deviceType"] = "3";
          } else {
            if (io.Platform.isAndroid) {
              header["source_type"] = "1";
              header["deviceType"] = "1";
            } else if (io.Platform.isIOS) {
              header["source_type"] = "1";
              header["deviceType"] = "2";
            }
          }
          print("headers =444444");

          int milliseconds =  DateTime.now().millisecondsSinceEpoch;
          int timestamp = milliseconds~/ 1000;

          print("headers =333333");
          header["Content-Type"] = "application/json";
          header["deviceId"] = DataManager.getDeviceId();
          header["os"] = DataManager.getSystemVersion();
          header["model"] = DataManager.getAppModel();
          header["version"] = DataManager.getAppVersion();
          header["build"] = DataManager.getAppBuildVersion();
          header["timestamp"] = timestamp.toString();
          header["channelNo"] = "yuyueapp_iosyy";
          header["Authorization"] = token;

          options.headers
              .addAll(header);


          print("headers = ${options.headers}");

          return handler.next(options);
        },

        /// 响应时的处理
        onResponse: (Response response, handler) {
          print("\n================== 响应数据 ==========================");
          // YLLog.d("headers = ${response.requestOptions.headers}======${response.headers}");
          print("code = ${response.statusCode}");
          print("data = ${response.data}");
          print("\n");

          return handler.next(response);
        },
        onError: (DioException e, handler) {

          print("\n================== 错误响应数据 ======================");
          // YLLog.d("headers = ${e.requestOptions.headers}======${e.response.headers}");
          print("type = ${e.type}");
          print("error = ${e.error}");
          print("message = ${e.message}");
          print("\n");
          // showToast(e.message);
          return handler.next(e);
        },
      ))

    /// 添加 LogInterceptor 拦截器来自动打印请求、响应日志
      ..add(LogInterceptor(
        request: false,
        responseBody: true,
        responseHeader: true,
        requestHeader: true,
      ));
  }

  /// Make http request with options.
  ///
  /// [method] The request method.
  /// [path] The url path.
  /// [data] The request data
  ///
  /// String 返回 json data .
  Future<Response?> request(
      String path, {
        Map<String, dynamic>? data,
        String method = postType,
        CancelToken? cancelToken,
      }) async {
    if (data != null) {
      /// restful 请求处理
      /// /gysw/search/hist/:user_id        user_id=27
      /// 最终生成 url 为     /gysw/search/hist/27
      data.forEach((key, value) {
        if (path.contains(key)) {
          path = path.replaceAll(':$key', value.toString());
        }
      });
    }

    Response? response;
    try {
      response = await dio.request(

        /// 请求路径，如果 `path` 以 "http(s)"开始, 则 `baseURL` 会被忽略； 否则, 将会和baseUrl拼接出完整的的url.
          path,
          data: data != null ? json.encode(data) : null,
          queryParameters: data,
          options: Options(method: method), onReceiveProgress: (int count, int total) {
        print('onReceiveProgress: ${(count / total * 100).toStringAsFixed(0)} %==FormData===${data != null ? FormData.fromMap(data) : null}');
      }, onSendProgress: (int count, int total) {
        print('onSendProgress: ${(count / total * 100).toStringAsFixed(0)} %');
      }, cancelToken: cancelToken);
    } on DioException catch (e) {
      formatError(e);

      /// 响应信息, 如果错误发生在在服务器返回数据之前，它为 `null`
      print('$method请求发生错误：${e.response}');
    }
    print('response===dio.request: ${response}');
    return response;
  }

  Future<Response?> download(url, savePath,
      {Function(int count, int total)? onReceiveProgress, CancelToken? cancelToken}) async {
    print('download请求启动! url：$url===savepath=$savePath');
    Response? response;
    try {
      response =
      await Dio().download(url, savePath, cancelToken: cancelToken, onReceiveProgress: (int count, int total) {
        print('onReceiveProgress: ${(count / total * 100).toStringAsFixed(0)} %');
        onReceiveProgress!(count, total);
      });
    } on DioException catch (e) {
      print('download fail =$e=response= ${e.response.toString()}');
      formatError(e);
    }


    return response;
  }

  /// 上传文件
  ///
  /// [path] The url path.
  /// [data] The request data
  ///
  Future<Response?> uploadFile(String path, {String baseUrl = RELEASE_API, required FormData data}) async {
    /// 打印请求相关信息：请求地址、请求方式、请求参数
    print("请求地址：【$baseUrl$path】");
    print('请求参数：$data');
    Response? response;
    try {
      response = await Dio(
        BaseOptions(baseUrl: baseUrl, connectTimeout:const Duration(milliseconds: 15000), receiveTimeout: const Duration(milliseconds: 15000)),
      ).post(path, data: data, onReceiveProgress: (int count, int total) {
        print('onReceiveProgress: ${(count / total * 100).toStringAsFixed(0)} %');
      }, onSendProgress: (int count, int total) {
        print('onSendProgress: ${(count / total * 100).toStringAsFixed(0)} %');
      });

      /// 响应数据，可能已经被转换了类型, 详情请参考Options中的[ResponseType].
      print('请求成功!response.data：${response.data}');

      /// 响应头
      print('请求成功!response.headers：${response.headers}');

      /// Http status code.
      print('请求成功!response.statusCode：${response.statusCode}');
    } on DioException catch (e) {
      print(e.response.toString());
      formatError(e);
    }

    return response;
  }

  /// error统一处理
  void formatError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      // It occurs when url is opened timeout.
      print("连接超时 Ծ‸ Ծ");
    } else if (e.type == DioExceptionType.sendTimeout) {
      // It occurs when url is sent timeout.
      print("请求超时 Ծ‸ Ծ");
    } else if (e.type == DioExceptionType.receiveTimeout) {
      //It occurs when receiving timeout
      print("响应超时 Ծ‸ Ծ");
    } else if (e.type == DioExceptionType.badResponse) {
      // When the server response, but with a incorrect status, such as 404, 503...
      print("出现异常 Ծ‸ Ծ");
    } else if (e.type == DioExceptionType.cancel) {
      // When the request is cancelled, dio will throw a error with this type.
      print("请求取消 Ծ‸ Ծ");
    } else {
      //DEFAULT Default error type, Some other Error. In this case, you can read the DioException.error if it is not null.
      print("未知错误 Ծ‸ Ծ");
    }
  }

  /// 取消请求
  ///
  /// 同一个cancel token 可以用于多个请求，当一个cancel token取消时，所有使用该cancel token的请求都会被取消。所以参数可选
  void cancelRequests(CancelToken token) {
    token.cancel("cancelled");
  }

  get(String path, Function successCallBack,
      {Map<String, dynamic>? params,
        CancelToken? cancelToken,
        Function(Map error)? errorCallBack,
        bool useBaseResult = true}) async {
    _requestHttp(path, successCallBack,
        method: getType,
        params: params,
        errorCallBack: errorCallBack!,
        cancelToken: cancelToken!,
        useBaseResult: useBaseResult);
  }

  post(String path, Function successCallBack,
      {Map<String, dynamic>? params,
        CancelToken? cancelToken,
        Function(Map error)? errorCallBack,
        bool useBaseResult = true}) async {
    _requestHttp(path, successCallBack,
        method: postType,
        params: params != null ? FormData.fromMap(params) : null,
        errorCallBack: errorCallBack!,
        cancelToken: cancelToken!,
        useBaseResult: useBaseResult);
  }

  delete(String path, Function successCallBack,
      {Map<String, dynamic>? params,
        CancelToken? cancelToken,
        Function(Map error)? errorCallBack,
        bool useBaseResult = true}) async {
    _requestHttp(path, successCallBack,
        method: deleteType,
        params: params,
        errorCallBack: errorCallBack!,
        cancelToken: cancelToken!,
        useBaseResult: useBaseResult);
  }

  _requestHttp(String path, Function successCallBack,
      {required String method,
        dynamic params,
        Function(Map error)? errorCallBack,
        CancelToken? cancelToken,
        bool? useBaseResult}) async {
    Response? response;
    try {
      if (method == getType) {
        if (null != params && params.isNotEmpty) {
          response = await dio.get(path, queryParameters: params, cancelToken: cancelToken);
        } else {
          response = await dio.get(path, cancelToken: cancelToken);
        }
      } else if (method == postType) {
        response = await dio.post(path, data: params, queryParameters: params, onSendProgress: (int count, int total) {
          print('onSendProgress: ${(count / total * 100).toStringAsFixed(0)} %');
        }, cancelToken: cancelToken);
      } else if (method == deleteType) {
        response = await dio.delete(path, queryParameters: params, cancelToken: cancelToken);
      }
    } on DioException catch (error) {
      // 请求错误处理
      print(error.response.toString());
      formatError(error);
      _error(errorCallBack!, {"message": error.message});
    }

    int statusCode = response!.statusCode!;

    if (statusCode >= 200 && statusCode < 300) {
      if (useBaseResult!) {
        ResultModel? result = ResultModel.fromMap(json.decode(response.data!));
        if (result.code != "0") {
          _error(errorCallBack!, json.decode(response.data));
        } else {
          successCallBack(result.result);
        }

      } else {
        successCallBack(json.decode(response.data));
      }
    } else {
      _error(errorCallBack!, {"message": response.statusMessage, "code": statusCode});
    }
  }

  _error(Function(Map error) errorCallBack, Map map) {
    errorCallBack(map);
  }

}

class ResultModel<T> {
  String code;
  String message;
  Map<String,dynamic>? result;

  ResultModel({this.code = "", this.message = "", this.result});

  static ResultModel fromMap(Map<String, dynamic> map) {


    ResultModel model = ResultModel();
    model.code = '${map['code']}';
    model.message = map['message'];
    dynamic data = map['result'];
    if (data is String) {
      String dataString = map['result'];

      model.result = {"data":dataString};
      print('result.data=====$dataString');
    } else if (data is Map) {
      model.result = {"data":data};


      print('result.data=====$data');
    }  else if (data is List) {
      model.result = {"data":data};

      print('result.data=====$data');
    } else {
      model.result = {"data":""};
    }

    return model;
  }

  Map<String, dynamic> toJson() => {
    "code": code,
    "msg": message,
    "result": result,
  };
}



class LoadingHud {



  static LoadingHud? _instance;

  static Future<LoadingHud> getInstance() async {
    _instance ??= await LoadingHud._()._init();
    return _instance!;
  }

  LoadingHud._();

  Future _init() async {



  }

  static showHud(context, {String toast = ""}) {

    showDialog(
      barrierColor : const Color(0x0c000000),
      barrierDismissible : true,
      context: context,
      builder: (context) {
        return Center(
            child: Container(
              decoration:const BoxDecoration(
                color: Color(0x33FA6E71),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              width: toast.isEmpty ? 120 : 180,
              height:toast.isEmpty ? 120 : 180,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PacmanIndicator(color:const Color(0xffFA6E71)),
                  toast.isEmpty ? const SizedBox.shrink() :const SizedBox(height: 20,),
                  toast.isEmpty ?
                  const SizedBox.shrink() :
                  Padding(
                    padding:const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      toast,
                      textAlign: TextAlign.center,

                      style:const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          decoration: TextDecoration.none
                      ),
                    ),
                  ),
                ],
              ),
            ));
      },

    );

  }
  static dismissHud(context) {
    Navigator.of(context).pop();
  }

}

class PacmanIndicator extends StatefulWidget {
  PacmanIndicator({super.key,
    this.radius = 30,
    this.beanRadius = 4,
    this.color= Colors.white,
    this.duration= const Duration(milliseconds: 325),
  });

  final double radius;
  final double beanRadius;
  final Color color;
  final Duration duration;

  @override
  State<StatefulWidget> createState() => _PacmanIndicatorState();
}

class _PacmanIndicatorState extends State<PacmanIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> pacman;
  late Animation<double> bean;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: widget.duration);
    pacman = Tween<double>(begin: 0, end: 90)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    bean = Tween<double>(begin: 0, end: widget.radius * .5)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Size _measureSize() {
    var width = (widget.radius + widget.beanRadius) * 2;
    var height = widget.radius * 2;
    return Size(width, height);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => CustomPaint(
          size: _measureSize(),
          painter: _PacmanIndicatorPainter(
            pacmanAngle: pacman.value,
            beanTransX: bean.value,
            radius: widget.radius,
            beanRadius: widget.beanRadius,
            color: widget.color,
          ),
        ));
  }
}

double _progress = .0;
double _lastExtent = .0;

class _PacmanIndicatorPainter extends CustomPainter {
  _PacmanIndicatorPainter({
    this.pacmanAngle,
    this.beanTransX,
    this.radius,
    this.beanRadius,
    this.color,
  });

  final double? pacmanAngle;
  final double? beanTransX;
  final double? radius;
  final double? beanRadius;
  final Color? color;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = color!;

    var width = radius! * 2;
    var height = radius! * 2;
    var radian = pi / 180;
    Rect rect = Rect.fromLTWH(0, 0, width, height);
    canvas.drawArc(rect, (0 + pacmanAngle! * .5) * radian,
        (360 - pacmanAngle!) * radian, true, paint);

    _progress += (_lastExtent - beanTransX!).abs();
    _lastExtent = beanTransX!;
    if (_progress >= radius!) {
      _progress = .0;
      _lastExtent = .0;
    }

    var beanAlpha = 255 - (122.5 * _progress / radius!);
    paint.color =
        Color.fromARGB(beanAlpha.round(), color!.red, color!.green, color!.blue);

    var cx = width + beanRadius!;
    var cy = size.height * .5;
    canvas.drawCircle(Offset(cx - _progress, cy), beanRadius!, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class DataManager {

  static SharedPreferences? _prefs;

  static DataManager? _instance;

  static Future<DataManager?> getInstance() async {
    _instance ??= await DataManager._()._init();
    return _instance;
  }

  DataManager._();

  Future _init() async {

    _prefs = await SharedPreferences.getInstance();


    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String version = packageInfo.version;

    DataManager.setAppVersion(version);
    DataManager.setAppName(appName);
    DataManager.setAppBuildVersion(packageInfo.buildNumber);

    if (kIsWeb) {
      final deviceData = await DeviceInfoPlugin().webBrowserInfo;
      DataManager.setDeviceId(deviceData.appCodeName);
      DataManager.setSystemVersion(deviceData.appVersion);
      DataManager.setAppModel(deviceData.appVersion);

    } else {
      if (io.Platform.isAndroid) {
        final deviceData = await DeviceInfoPlugin().androidInfo;

        DataManager.setDeviceId(deviceData.device);
        DataManager.setSystemVersion(deviceData.version.release);
        DataManager.setAppModel(deviceData.model);

      } else if (io.Platform.isIOS) {
        final deviceData = await DeviceInfoPlugin().iosInfo;
        print('identifierForVendor====${deviceData.identifierForVendor}');

        DataManager.setDeviceId(deviceData.identifierForVendor);
        DataManager.setSystemVersion(deviceData.systemVersion);
        DataManager.setAppModel(deviceData.utsname.machine);

      }
    }

  }

  static setAppModel(version) {

    return _prefs!.setString("AppModelKey", version);
  }

  static getAppModel() {

    return _prefs!.getString("AppModelKey") ?? "";
  }


  static setAppVersion(version) {

    return _prefs!.setString("appVersionKey", version);
  }

  static getAppVersion() {

    return _prefs!.getString("appVersionKey") ?? "";
  }

  static setAppBuildVersion(version) {

    return _prefs!.setString("AppBuildVersionKey", version);
  }

  static getAppBuildVersion() {

    return _prefs!.getString("AppBuildVersionKey") ?? "";
  }

  static setDeviceId(version) {

    return _prefs!.setString("DeviceIdKey", version);
  }

  static getDeviceId() {

    return _prefs!.getString("DeviceIdKey") ?? "";
  }

  static setSystemVersion(version) {

    return _prefs!.setString("SystemVersionKey", version);
  }

  static getSystemVersion() {

    return _prefs!.getString("SystemVersionKey") ?? "";
  }

  static setAppName(name) {

    return _prefs!.setString("appNameKey", name);
  }

  static getAppName() {

    return _prefs!.getString("appNameKey") ?? "";
  }

}

class InviteListData {

  late String headImg;
  late String nickName;
  late String profitAmt;
  late String inviteTime;
  late int userId;
  late int lailiaoNum;


  InviteListData({
    this.headImg = "",
    this.nickName = "",
    this.profitAmt = "",
    this.inviteTime = "",
    this.userId = 0,
    this.lailiaoNum = 0,
  });

  InviteListData.fromJson(Map<String, dynamic> json) {
    headImg = json['headImg']?.toString() ?? "";
    nickName = json['nickName']?.toString() ?? "";
    profitAmt = json['profitAmt']?.toString() ?? "";
    inviteTime = json['inviteTime']?.toString() ?? "";
    userId = json['userId'] ?? 0;
    lailiaoNum = json['lailiaoNum'] ?? 0;

  }
  Map<String, dynamic> toJson() {

    final data = <String, dynamic>{};

    data['headImg'] = headImg;
    data['nickName'] = nickName;
    data['profitAmt'] = profitAmt;
    data['inviteTime'] = inviteTime;
    data["userId"] = userId;
    data["lailiaoNum"] = lailiaoNum;
    return data;
  }

}

enum ImageViewType { network, assets, localFile }


class ImageView extends StatelessWidget {
  /// 图片URL
  final String path;

  /// 圆角半径
  final double radius;

  /// 宽
  final double? width;

  /// 高
  final double? height;

  /// 填充效果
  final BoxFit fit;

  /// 加载中图片
  String? placeholder;

  ///
  final ImageViewType imageType;

  /// 透明度
  final double opacity;

  final double sigmaX;
  final double sigmaY;

  /// 过滤颜色
  final Color filterColor;

  final Widget? child;
  final EdgeInsetsGeometry padding;

  /// 图片外边框
  final EdgeInsetsGeometry margin;

  /// 子控件位置
  final AlignmentGeometry alignment;

  final double elevation;

  final BoxShape shape;

  final Color? borderColor;

  final double borderWidth;


  ImageView(
      this.path, {
        Key? key,
        this.radius = 0.0,
        this.width,
        this.height,
        this.margin = EdgeInsets.zero,
        this.fit = BoxFit.cover,
        this.placeholder,
        this.imageType = ImageViewType.network,
        this.opacity = 1.0,
        this.sigmaX = 0.0,
        this.sigmaY = 0.0,
        this.filterColor = Colors.transparent,
        this.child,
        this.alignment = Alignment.center,
        this.padding = EdgeInsets.zero,
        this.elevation = 0.0,
        this.shape = BoxShape.rectangle,
        this.borderColor,
        this.borderWidth = 0.0,
      })  : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    placeholder ??= "lib/head.png";

    switch (imageType) {
      case ImageViewType.network:
        imageWidget = CachedNetworkImage(
            placeholder: (context, url) => Image.asset(placeholder!),
            imageUrl: path,
            fit: fit,
            errorWidget: (context, url, error) => Image.asset(placeholder!));
        break;
      case ImageViewType.assets:
        imageWidget = FadeInImage(placeholder: AssetImage(placeholder!), image: AssetImage(path), fit: fit);
        break;
      case ImageViewType.localFile:
        imageWidget = FadeInImage(placeholder: AssetImage(placeholder!), image: FileImage(io.File(path)), fit: fit);
        break;
    }

    return Card(
        color: Colors.transparent,
        shape: shape == BoxShape.circle
            ? const CircleBorder()
            : RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        clipBehavior: Clip.antiAlias,
        elevation: elevation,
        margin: margin,
        child: SizedBox(
            height: height ?? double.infinity,
            width: width ?? double.infinity,
            child: Stack(children: <Widget>[
              Positioned.fill(child: imageWidget),
              Positioned.fill(
                  child: Container(
                      decoration: BoxDecoration(
                          shape: shape,
                          borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(radius),
                          border: Border.all(
                              color: borderColor ?? Theme.of(context).primaryColor,
                              width: borderWidth,
                              style: borderWidth == 0.0 ? BorderStyle.none : BorderStyle.solid)))),
              BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
                  child: Opacity(
                      opacity: opacity,
                      child: Container(
                          color: filterColor,
                          alignment: alignment,
                          padding: padding,
                          child: child ?? const SizedBox())))
            ])));
  }
}