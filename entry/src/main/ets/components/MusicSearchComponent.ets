import router from '@ohos.router';
import AvaterComponent from '../components/AvaterComponent';
import * as colors from '../theme/color';
import * as size from '../theme/size';
import { MusicInterface } from '../interface/Index';
import { getKeyWordMusicService } from '../service/Index';
import { RECOMMEND_COVER } from '../common/constant';

@Component
export default struct MusicSearchComponent {
  @State dimensions: number = size.middleAvater; // 导入的值不能直接传给组件
  @State musicItem: MusicInterface | null = null

  @Styles
  blockStyle(){
    .backgroundColor(colors.white)
    .borderRadius(size.middleBorderRaduis)
    .padding(size.middleGap)
    .width('100%')
    .margin({ top: size.middleGap })
  }

  /**
   * @description: 获取推荐的音乐
   * @date: 2024-03-02 22:44
   * @author wuwenqiang
   */
  useSearchKeyWord() {
    getKeyWordMusicService().then((res) => {
      this.musicItem = res.data;
      // 首页导航栏中间凸起组件在没有播放中的音乐时，用推荐音乐的封面兜底；
      // 接口 data 为 null（或没有 cover）时写入空串，由首页回退到默认歌曲图标
      AppStorage.SetOrCreate<string>(RECOMMEND_COVER, res.data?.cover ?? '');
    });
  }

  aboutToAppear() {
    this.useSearchKeyWord()
  }

  build() {
    Row({space:size.middleGap}) {
      AvaterComponent({ dimensions: this.dimensions })
      Row() {
        Text(this.musicItem?.songName)
          .fontSize(size.middleFont)
          .fontColor(colors.gray)
      }
      .height(size.middleAvater)
      .borderRadius(size.middleAvater)
      .backgroundColor(colors.pageBackground)
      .padding({ left: size.middleGap })
      .flexGrow(1)
      .onClick(() => {
        router.pushUrl({
          url: 'pages/MusicSearchPage', // 目标url
          params: {
            musicItem: this.musicItem
          }
        }, router.RouterMode.Standard, (err) => {
          if (err) {
            console.error(`Invoke showAlertBeforeBackPage failed, code is ${err.code}, message is ${err.message}`);
          }
        });
      })
      Image($r("app.media.icon_ai"))
        .width(size.middleIcon)
        .height(size.middleIcon)
        .onClick(()=>{
          router.pushUrl({
            url:"pages/ChatPage"
          })
        })
    }.blockStyle()
  }
}