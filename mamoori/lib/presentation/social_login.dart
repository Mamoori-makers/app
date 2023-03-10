import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:mamoori/presentation/wills/wills_view.dart';

class SocialLogin extends StatelessWidget {
  const SocialLogin({Key? key}) : super(key: key);

  void _get_user_info(context) async {
    try {
      User user = await UserApi.instance.me();
      print('사용자 정보 요청 성공'
          '\n회원번호: ${user.id}'
          '\n닉네임: ${user.kakaoAccount?.profile?.nickname}');
      if (user.id != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WillsView(title: '마무리'), // 로그인 화면으로 다시 가야 함
            ));
      }
    } catch (error) {
      print('사용자 정보 요청 실패 $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/mamoori.png',
            width: 80,
            height: 80,
          ),
          const SizedBox(height: 50),
          Center(
            child: GestureDetector(
                onTap: () async {
                  if (await isKakaoTalkInstalled()) {
                    try {
                      await UserApi.instance.loginWithKakaoTalk();
                      _get_user_info(context);
                    } catch (error) {
                      // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
                      try {
                        await UserApi.instance.loginWithKakaoAccount();
                        _get_user_info(context);
                      } catch (error) {
                        print('카카오계정으로 로그인 실패 $error');
                      }
                    }
                  } else {
                    try {
                      await UserApi.instance.loginWithKakaoAccount();
                      _get_user_info(context);
                    } catch (error) {
                      print('카카오계정으로 로그인 실패 $error');
                    }
                  }
                },
                child:
                    Image.asset('assets/kakao/kakao_login_medium_narrow.png')),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
