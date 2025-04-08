import * as colors from '../theme/color';
import * as size from '../theme/size';
import AvaterComponent from '../components/AvaterComponent';
import { HOST, USER_DATA } from '../common/constant';
import { getFavoriteAuthorService, getMusicPlayMenuService, getMusicRecordService, getFavoriteDirectoryService } from '../service/Index';
import { MusicAuthorInterface } from '../interface';
import { FavoriteDirectoryInterface, MusicInterface,UserDataInterface } from '../interface/Index';
import router from '@ohos.router';
import MusicAvaterComponent from './MusicAvaterComponent';

@Component
export default struct MusicMyComponent {
  scroller: Scroller = new Scroller()
  @StorageLink(USER_DATA) userData: UserDataInterface = null;
  @State dimensions: number = size.middleAvaterSize; // 导入的值不能直接传给组件
  @State myFavoriteDirectoryList: Array<FavoriteDirectoryInterface> = []; // 我的歌单
  @State myFavoriteAuthorList: Array<MusicAuthorInterface> = []; // 我关注的歌手列表
  @State myRecordMusicList: Array<MusicInterface> = []; // 我听过的歌曲
  @State myCreateMusicList: Array<MusicInterface> = []; // 我创作的歌曲
  @State isFoldFavoriteDirectory: boolean = false; // 是否折叠我的歌单
  @State isFoldRecordMusic: boolean = false; // 是否折叠我听过的歌曲
  @State isFoldFavoriteAuthor: boolean = false; // 是否折叠我关注的歌手
  @State myFavoriteAuthorTotal: number = 0; // 我关注的歌手总数
  @State myRecordMusicTotal: number = 0; // 我听过的歌曲总数

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({ top: size.pagePadding })
  }

  /**
   * @description: 跳转到歌单列表页
   * @date: 2024-07-16 22:37
   * @author wuwenqiang
   */
  useMusicFavoriteList(item:FavoriteDirectoryInterface){
    router.pushUrl({
      url: 'pages/MusicFavoriteListPage', // 目标url
      params: {
        favoriteDirectory: item
      }
    });
  }

  aboutToAppear() {
    getFavoriteAuthorService(1, 5).then((res) => {
      this.myFavoriteAuthorTotal = res.total;
      this.myFavoriteAuthorList = res.data;
    });
    getFavoriteDirectoryService(0).then(res =>{
      this.myFavoriteDirectoryList = res.data;
    });
    getMusicRecordService(1, 10).then(res => {
      this.myRecordMusicTotal = res.total;
      this.myRecordMusicList = res.data;
    });
  }

  build() {
    Scroll(this.scroller) {
      Column() {
        Row() {
          AvaterComponent({ dimensions: this.dimensions })
          Column() {
            Text(this.userData?.username).fontWeight(FontWeight.Bold)
            Text(this.userData?.sign).fontColor(colors.disableTextColor)
          }.layoutWeight(1).alignItems(HorizontalAlign.Start).margin({ left: size.pagePadding })
          Image($r('app.media.icon_edit'))
            .height(size.bigIconSize)
            .width(size.bigIconSize)
            .onClick(() => router.pushUrl({ url: 'pages/UserPage'}))
        }.blockStyle().alignItems(VerticalAlign.Center)

        Column() {
          Row() {
            Image($r("app.media.icon_down"))
              .width(size.smallIconSize)
              .height(size.smallIconSize)
              .colorFilter(colors.borderColor)
              .onClick(() => {
                this.isFoldFavoriteDirectory = !this.isFoldFavoriteDirectory;
                getMusicPlayMenuService().then(res => {
                  this.myFavoriteDirectoryList = res.data;
                });
              }).rotate({ angle: this.isFoldFavoriteDirectory ? 90 : 0 })
            Text("我的歌单").margin({ left: size.pagePadding })
            Blank()
            Image($r("app.media.icon_add")).width(size.smallIconSize).height(size.smallIconSize)
          }.width('100%')
          if (!this.isFoldFavoriteDirectory) {
            Blank().height(size.pagePadding)
            ForEach(this.myFavoriteDirectoryList, (item: FavoriteDirectoryInterface,index:number) => {
              Row({space:size.pagePadding}) {
                MusicAvaterComponent({avater:item.cover?.toString(),title:item.name[0],dimension:Number(size.middleAvaterSize),type:'music'})
                Column() {
                  Text(item.name)
                  Text(item.total.toString() + '首').fontColor(colors.disableTextColor)
                }.alignItems(HorizontalAlign.Start)
                Blank()
                Image($r("app.media.icon_music_play"))
                  .width(size.smallIconSize)
                  .height(size.smallIconSize)
                Image($r("app.media.icon_music_menu"))
                  .width(size.smallIconSize)
                  .height(size.smallIconSize)
              }
              .width('100%')
              .onClick(() => this.useMusicFavoriteList(item))
              if(index !== this.myFavoriteDirectoryList.length - 1){
                Blank().height(size.pagePadding)
                Divider().height(1).color(colors.borderColor)
                Blank().height(size.pagePadding)
              }
            })
          }
        }.blockStyle()

        Column() {
          Row() {
            Image($r("app.media.icon_down"))
              .width(size.smallIconSize)
              .height(size.smallIconSize)
              .colorFilter(colors.borderColor)
              .onClick(() => {
                this.isFoldFavoriteAuthor = !this.isFoldFavoriteAuthor;
                if (!this.isFoldFavoriteAuthor) {
                  getFavoriteAuthorService(1, 5).then((res) => {
                    this.myFavoriteAuthorTotal = res.total;
                    this.myFavoriteAuthorList = res.data;
                  });
                }
              }).rotate({ angle: this.isFoldFavoriteAuthor ? 90 : 0 })
            Text("我关注的歌手").margin({ left: size.pagePadding })
            if (this.myFavoriteAuthorTotal > 5) {
              Blank()
              Text("更多").fontColor(colors.disableTextColor).decoration({
                type: TextDecorationType.Underline,
                color: colors.disableTextColor
              }).onClick(()=>{

              })
            }
            Blank()
          }.width('100%')

          if (!this.isFoldFavoriteAuthor) {
            Blank().height(size.pagePadding)
            ForEach(this.myFavoriteAuthorList, (item: MusicAuthorInterface,index:number) => {
              Row() {
                Image(item.avatar ? (/http[s]?:\/\//.test(item.avatar) ? item.avatar.replace('{size}', '480') : HOST + item.avatar) : $r("app.media.default_avater"))
                  .width(size.middleAvaterSize)
                  .height(size.middleAvaterSize)
                  .borderRadius(size.middleAvaterSize)
                Column() {
                  Text(item.authorName)
                  Text(item.total.toString() + '首').fontColor(colors.disableTextColor)
                }.margin({ left: size.pagePadding }).alignItems(HorizontalAlign.Start)

                Blank()
                Image($r("app.media.icon_music_play"))
                  .width(size.smallIconSize)
                  .height(size.smallIconSize)
                  .margin({ left: size.pagePadding })
                Image($r("app.media.icon_music_menu"))
                  .width(size.smallIconSize)
                  .height(size.smallIconSize)
                  .margin({ left: size.pagePadding })
              }.width('100%')
              if(index !== this.myFavoriteAuthorList.length - 1){
                Blank().height(size.pagePadding)
                Divider().height(1).color(colors.borderColor)
                Blank().height(size.pagePadding)
              }
            })
          }
        }.blockStyle()

        Column() {
          Row() {
            Image($r("app.media.icon_down"))
              .width(size.smallIconSize)
              .height(size.smallIconSize)
              .colorFilter(colors.borderColor)
              .onClick(() => {
                this.isFoldRecordMusic = !this.isFoldRecordMusic;
                if (!this.isFoldRecordMusic) {
                  getMusicRecordService(1, 10).then(res => {
                    this.myRecordMusicTotal = res.total;
                    this.myRecordMusicList = res.data;
                  });
                }
              }).rotate({ angle: this.isFoldRecordMusic ? 90 : 0 })
            Text("我听过的歌曲").margin({ left: size.pagePadding })
            if (this.myRecordMusicTotal > 10) {
              Blank()
              Text("更多").fontColor(colors.disableTextColor).decoration({
                type: TextDecorationType.Underline,
                color: colors.disableTextColor
              }).onClick(()=>{
                router.pushUrl({ url: 'pages/RecordMusicPage'})
              })
            }
          }.width('100%')

          if (!this.isFoldRecordMusic) { // 如果是展开状态
            Blank().height(size.pagePadding)
            ForEach(this.myRecordMusicList, (item: MusicInterface,index:number) => {
              Row() {
                Image(item.cover ? (/http[s]?:\/\//.test(item.cover) ? item.cover.replace('{size}', '480') : HOST + item.cover) : $r("app.media.default_avater"))
                  .width(size.middleAvaterSize)
                  .height(size.middleAvaterSize)
                  .borderRadius(size.middleAvaterSize)
                Column() {
                  Text(item.songName)
                  Text(`听过${item.times.toString()}次`).fontColor(colors.disableTextColor)
                }.margin({ left: size.pagePadding }).alignItems(HorizontalAlign.Start)

                Blank()
                Image($r("app.media.icon_music_play"))
                  .width(size.smallIconSize)
                  .height(size.smallIconSize)
                  .margin({ left: size.pagePadding })
                Image($r("app.media.icon_music_menu"))
                  .width(size.smallIconSize)
                  .height(size.smallIconSize)
                  .margin({ left: size.pagePadding })
              }.width('100%')
              if(index !== this.myRecordMusicList.length - 1){
                Blank().height(size.pagePadding)
                Divider().height(1).color(colors.borderColor)
                Blank().height(size.pagePadding)
              }
            })
          }
        }.blockStyle()
        Blank().height(size.pagePadding)
      }
    }
    .scrollable(ScrollDirection.Vertical)
    .width("100%")
    .height("100%")
    .align(Alignment.Top)
    .backgroundColor(colors.pageBackgroundColor)
    .padding({ left: size.pagePadding, right: size.pagePadding, })
  }
}