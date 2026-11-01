import * as colors from '../theme/color';
import * as size from '../theme/size';
import { getMusicAuthorListByCategoryIdService } from '../service/Index';
import { MusicAuthorInterface } from '../interface/Index';
import router from '@ohos.router';
import MusicAvaterComponent from './MusicAvaterComponent';

@Component
export default struct MusicAuthorComponent {
  @Styles
  blockStyle(){
    .backgroundColor(colors.white)
    .borderRadius(size.middleBorderRaduis)
    .padding(size.middleGap)
    .width('100%')
    .margin({ top: size.middleGap })
  }

  @State authorList: Array<MusicAuthorInterface> = [];

  aboutToAppear() {

    /**
     * @description: 获取歌手列表前4条数据
     * @date: 2024-03-05 22:40
     * @author wuwenqiang
     */
    getMusicAuthorListByCategoryIdService(0, 1, 4).then((res) => {
      this.authorList = res.data;
    })
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.icon_down'))
          .width(size.smallIcon)
          .height(size.smallIcon)
        Text("推荐歌手").margin({ left: size.middleGap }).layoutWeight(1)
        Text("更多").onClick(() => {
          router.pushUrl({
            url: 'pages/MusicAuthorCategoryPage', // 目标url
          })
        })
      }.alignItems(VerticalAlign.Center).margin({ bottom: size.middleGap })

      Row() {
        ForEach(this.authorList, (item: MusicAuthorInterface) => {
          Column() {
            MusicAvaterComponent({
              avater: item.avatar?.toString(),
              title: item.authorName[0],
              dimension: Number(size.middleAvater * 1.5),
              type: 'author'
            })
            Text(item.authorName).margin({ top: size.smallGap })
          }
          .width('25%')
          .alignItems(HorizontalAlign.Center)
          .onClick(()=>{
            router.pushUrl({
              url: 'pages/MusicAuthorMusicListPage', // 目标url
              params:{
                musicAuthor:item
              }
            })
          })
        })
      }
    }.blockStyle()

  }
}