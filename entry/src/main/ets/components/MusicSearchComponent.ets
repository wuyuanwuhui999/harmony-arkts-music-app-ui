import router from '@ohos.router';
import AvaterComponent from '../components/AvaterComponent';
import * as colors from '../theme/color';
import * as size from '../theme/size';
import { MusicInterface } from '../interface/Index';
import { getKeyWordMusicService } from '../service/Index';

@Component
export default struct MusicSearchComponent {
  @State dimensions: number = size.middleAvaterSize; // 导入的值不能直接传给组件
  @State musicItem: MusicInterface | null = null

  @Styles
  blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({ top: size.pagePadding })
  }

  /**
   * @description: 获取推荐的音乐
   * @date: 2024-03-02 22:44
   * @author wuwenqiang
   */
  useSearchKeyWord() {
    getKeyWordMusicService().then((res) => {
      this.musicItem = res.data;
    });
  }

  aboutToAppear() {
    this.useSearchKeyWord()
  }

  build() {
    Row({space:size.pagePadding}) {
      AvaterComponent({ dimensions: this.dimensions })
      Row() {
        Text(this.musicItem?.songName)
          .fontSize(size.normalFontSize)
          .fontColor(colors.disableTextColor)
      }
      .height(size.middleAvaterSize)
      .borderRadius(size.middleAvaterSize)
      .backgroundColor(colors.pageBackgroundColor)
      .padding({ left: size.pagePadding })
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
        .width(size.middlIconSize)
        .height(size.middlIconSize)
        .onClick(()=>{
          router.pushUrl({
            url:"pages/ChatPage"
          })
        })
    }.blockStyle()
  }
}