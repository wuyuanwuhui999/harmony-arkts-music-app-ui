import * as colors from '../theme/color';
import * as size from '../theme/size';
import { MusicInterface, MusicStorageInterface } from '../interface/Index';
import { MUSIC_STORAGE, PAGE_SIZE } from '../common/constant';
import { getMusicRecordService } from '../service/Index';
import { getMusicCover, useAppStorage, usePlayerRouter } from '../utils/common';
import NavigatorTitleComponent from '../components/NavigatorTitleComponent';

@Entry
@Component
export default struct RecordMusicPage {
  @StorageLink(MUSIC_STORAGE) musicStorage: MusicStorageInterface = useAppStorage()
  @State pageNum: number = 1;
  @State myRecordMusicList: Array<MusicInterface> = [];
  @State myRecordMusicTotal: number = 0;
  private loading: boolean = false;

  @Styles
  blockStyle(){
    .backgroundColor(colors.white)
    .borderRadius(size.middleBorderRaduis)
    .padding(size.middleGap)
    .width('100%')
  }

  aboutToAppear() {
    getMusicRecordService(this.pageNum, PAGE_SIZE).then(res => {
      this.myRecordMusicTotal = res.total;
      this.myRecordMusicList.push(...res.data);
    });
  }

  build() {
    Column() {
      NavigatorTitleComponent({ title: '我听过的歌曲' })
      Scroll() {
        Column() {
          Column() {
            ForEach(this.myRecordMusicList, (item: MusicInterface, index: number) => {
              Row() {
                Image(item.cover ? getMusicCover(item.cover) : $r("app.media.default_avater"))
                  .width(size.middleAvater)
                  .height(size.middleAvater)
                  .borderRadius(size.middleAvater)
                Column() {
                  Text(item.songName)
                  Text(`听过${item.times?.toString()}次`).fontColor(colors.gray)
                }.margin({ left: size.middleGap }).alignItems(HorizontalAlign.Start)

                Blank()
                Image($r("app.media.icon_music_play"))
                  .width(size.smallIcon)
                  .height(size.smallIcon)
                  .margin({ left: size.middleGap })
                Image($r("app.media.icon_music_menu"))
                  .width(size.smallIcon)
                  .height(size.smallIcon)
                  .margin({ left: size.middleGap })
              }.width('100%')

              if (index !== this.myRecordMusicList.length - 1) {
                Blank().height(size.middleGap)
                Divider().height(1).color(colors.borderColor)
                Blank().height(size.middleGap)
              }
            })
          }.justifyContent(FlexAlign.Start).blockStyle()

          if (this.myRecordMusicTotal) {
            Text(this.pageNum * PAGE_SIZE < this.myRecordMusicTotal ? "正在加载更多" : "已经到底了")
              .width("100%")
              .textAlign(TextAlign.Center)
              .padding({ top: size.middleGap })
              .fontColor(colors.gray)
          }
        }
      }
      .onScrollEdge((side: Edge) => {
        if (this.loading) {
          return;
        }
        if (this.pageNum * PAGE_SIZE < this.myRecordMusicTotal) {
          this.pageNum++;
          this.loading = true
          getMusicRecordService(this.pageNum, PAGE_SIZE).then(res => {
            this.myRecordMusicTotal = res.total;
            this.myRecordMusicList.push(...res.data);
          }).finally(() => this.loading = false);
        }
      }) // 滚动方向纵向
      .padding(size.middleGap)
      .align(Alignment.Top)
      .scrollable(ScrollDirection.Vertical)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(colors.pageBackground)
  }
}