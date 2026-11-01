import * as colors from '../theme/color';
import * as size from '../theme/size';
import emitter from '@ohos.events.emitter'
import { MusicInterface, MusicStorageInterface } from '../interface/Index';
import { getMusicListByCategoryIdService } from '../service/Index';
import { MUSIC_STORAGE } from '../common/constant';
import { LIKE_INNER_EVENT } from '../common/config';
import { usePlayerRouter, useAppStorage } from '../utils/common';
import router from '@ohos.router';
import MusicAvaterComponent from './MusicAvaterComponent';

@Component
export default struct MusicClassifyComponent {
  @Prop classifyId: number;
  @Prop classifyName: string;
  @State musicList: Array<MusicInterface> = []
  @StorageLink(MUSIC_STORAGE) musicStorage: MusicStorageInterface = useAppStorage()

  @Styles
  blockStyle(){
    .backgroundColor(colors.white)
    .borderRadius(size.middleBorderRaduis)
    .padding(size.middleGap)
    .width('100%')
    .margin({ top: size.middleGap })
  }

  aboutToAppear() {
    getMusicListByCategoryIdService(this.classifyId, 1, 4).then((res) => {
      this.musicList = res.data;
    });
    this.useLikeEmitter();
  }

  /**
   * @description: 监听音乐是否收藏
   * @date: 2024-07-07 18:54
   * @author wuwenqiang
   */
  useLikeEmitter() {
    emitter.on(LIKE_INNER_EVENT, (data: emitter.EventData) => {
      const musicModel: MusicInterface = data.data as MusicInterface;
      const musicItem = this.musicList.find(item => musicModel.id === item.id);
      musicItem && (musicItem.isLike = musicModel.isLike);
    });
  }

  /**
   * @description: 播放音乐分类
   * @date: 2024-07-17 22:23
   * @author wuwenqiang
   */
  async usePlayMusicList(musicModel: MusicInterface, index: number) {
    let musicList: Array<MusicInterface> = [];
    if (this.musicStorage.classifyName !== this.classifyName) {
      musicList = await getMusicListByCategoryIdService(this.classifyId, 1, 500).then(res => res.data)
    }
    usePlayerRouter(this.musicStorage, musicList, musicModel, this.classifyName, index)
  }

  aboutToDisappear() {
    emitter.off(LIKE_INNER_EVENT.eventId);
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.icon_down'))
          .width(size.smallIcon)
          .height(size.smallIcon)
          .opacity(0.5)
        Text(this.classifyName).margin({ left: size.middleGap }).layoutWeight(1)
        Text("更多").onClick(() => {
          router.pushUrl({
            url: 'pages/MusicClassifyListPage',
            params: {
              musicClassify: { id: this.classifyId, category: this.classifyName }
            }
          });
        })
      }.alignItems(VerticalAlign.Center)

      Column() {
        ForEach(this.musicList, (item: MusicInterface, index: number) => {
          Row({ space: size.middleGap }) {
            MusicAvaterComponent({
              avater: item.cover?.toString(),
              title: item.songName.toString(),
              dimension: Number(size.middleAvater),
              type: 'music'
            })
            Column() {
              Text(item.songName)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(item.authorName).margin({ top: size.smallGap / 2 })
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .fontColor(colors.gray)
            }.layoutWeight(1).alignItems(HorizontalAlign.Start)

            Image(this.musicStorage.musicItem?.id === item.id && this.musicStorage.classifyName === this.classifyName &&
            this.musicStorage.isPlaying ? $r("app.media.icon_music_playing_grey") : $r("app.media.icon_music_play"))
              .width(size.smallIcon)
              .height(size.smallIcon)
              .onClick(() => this.usePlayMusicList(item, index))
            Image((this.musicStorage.musicItem?.id === item.id && this.musicStorage.musicItem?.isLike === 1 ||
              item.isLike === 0) ? $r("app.media.icon_like") : $r("app.media.icon_like_active"))
              .width(size.smallIcon)
              .height(size.smallIcon)
            Image($r("app.media.icon_music_menu"))
              .width(size.smallIcon)
              .height(size.smallIcon)
          }
          .alignItems(VerticalAlign.Center)
          .margin({ top: size.middleGap })
          .padding({ bottom: index === this.musicList.length - 1 ? 0 : size.middleGap })
          .border({
            width: {
              bottom: index === this.musicList.length - 1 ? 0 : 1,
            },
            color: {
              bottom: colors.pageBackground
            },
            style: {
              bottom: BorderStyle.Solid
            }
          })
        })
      }
    }.blockStyle()
  }
}