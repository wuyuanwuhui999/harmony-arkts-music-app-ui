import * as colors from '../theme/color';
import * as size from '../theme/size';
import AvaterComponent from '../components/AvaterComponent';
import { HOST, USER_DATA } from '../common/constant';
import {
  getFavoriteAuthorService,
  getMusicPlayMenuService,
  getMusicRecordService,
  getFavoriteDirectoryService,
  deleteFavoriteDirectoryService,
  deleteFavoriteAuthorService,
  deleteMusicLikeService,
  getMusicListByFavoriteIdService,
  getMusicLikeService
} from '../service/Index';
import { MusicAuthorInterface } from '../interface/Index';
import { FavoriteDirectoryInterface, MusicInterface, UserDataInterface } from '../interface/Index';
import router from '@ohos.router';
import MusicAvaterComponent from './MusicAvaterComponent';
import BottomDialogComponent from './BottomDialogComponent';
import CreateFavoriteDirectory from './CreateFavoriteDirectory';
import promptAction from '@ohos.promptAction';
import display from '@ohos.display';
import DialogComponent from "./DialogComponent";
import { getMusicCover } from '../utils/common';

@Component
export default struct MusicMyComponent {
  scroller: Scroller = new Scroller()
  @StorageLink(USER_DATA) userData: UserDataInterface = {} as UserDataInterface;
  @State dimensions: number = size.middleAvaterSize; // 导入的值不能直接传给组件
  @State myFavoriteDirectoryList: Array<FavoriteDirectoryInterface> = []; // 我的歌单
  @State myFavoriteAuthorList: Array<MusicAuthorInterface> = []; // 我关注的歌手列表
  @State myRecordMusicList: Array<MusicInterface> = []; // 我听过的歌曲
  @State myLikeMusicList: Array<MusicInterface> = []; // 我创作的歌曲
  @State myLikeMusicTotal: number = 0;
  @State isFoldFavoriteDirectory: boolean = false; // 是否折叠我的歌单
  @State isFoldRecordMusic: boolean = false; // 是否折叠我听过的歌曲
  @State isFoldFavoriteAuthor: boolean = false; // 是否折叠我关注的歌手
  @State isFoldMusicLike: boolean = false; // 是否折叠我喜欢的音乐
  @State myFavoriteAuthorTotal: number = 0; // 我关注的歌手总数
  @State myRecordMusicTotal: number = 0; // 我听过的歌曲总数
  @State isShowAddDirectory: boolean = false; // 是否显示添加收藏夹弹窗
  private favoriteDialogController: CustomDialogController | null = null;
  private deleteDialogController: CustomDialogController | null = null;

  @Styles
  blockStyle(){
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
  useMusicFavoriteList(item: FavoriteDirectoryInterface) {
    router.pushUrl({
      url: 'pages/MusicFavoriteListPage', // 目标url
      params: {
        favoriteDirectory: item
      }
    });
  }

  /**
   * @description: 跳转到歌单列表页
   * @date: 2024-07-16 22:37
   * @author wuwenqiang
   */
  useAddDirectory() {
    this.favoriteDialogController = new CustomDialogController({
      customStyle: true,
      builder: BottomDialogComponent({
        dialogHeight: '80%',
        builder: this.favoriteBuilder.bind(this)
      }),
      alignment: DialogAlignment.Bottom,
    })
    this.favoriteDialogController.open()
  }

  /**
   * @author: wuwenqiang
   * @description: 收藏夹
   * @date: 2024-07-01 21:45
   */
  @Builder
  favoriteBuilder() {
    Column() {
      Row() {
        Blank()
          .width(size.smallIconSize)
          .height(size.smallIconSize)
          .margin({ right: size.pagePadding })
        Text('创建收藏夹')
          .padding(size.pagePadding)
          .textAlign(TextAlign.Center)
          .border({
            width: { bottom: 1 },
            color: { bottom: colors.borderColor },
            style: { bottom: BorderStyle.Solid }
          }).layoutWeight(1)
        Image($r("app.media.icon_close"))
          .width(size.smallIconSize)
          .height(size.smallIconSize)
          .opacity(0.5)
          .onClick(() => {
            this.favoriteDialogController?.close()
          })
          .margin({ right: size.pagePadding })
      }.justifyContent(FlexAlign.Center)

      CreateFavoriteDirectory({
        onCreateDirectory: (favoriteDirectory: FavoriteDirectoryInterface) => {
          this.favoriteDialogController?.close();
          this.myFavoriteDirectoryList.unshift(favoriteDirectory);
        },
        onCancleCreateDirectory: () => {
          this.favoriteDialogController?.close()
        }
      })
    }
  }

  aboutToAppear() {
    getMusicLikeService(1, 5).then((res) => {
      this.myLikeMusicTotal = res.total;
      this.myLikeMusicList = res.data;
    })
    getFavoriteAuthorService(1, 5).then((res) => {
      this.myFavoriteAuthorTotal = res.total;
      this.myFavoriteAuthorList = res.data;
    });
    getFavoriteDirectoryService(0).then(res => {
      this.myFavoriteDirectoryList = res.data;
    });
    getMusicRecordService(1, 10).then(res => {
      this.myRecordMusicTotal = res.total;
      this.myRecordMusicList = res.data;
    });
  }

  /**
   * @author: wuwenqiang
   * @description: 删除弹窗
   * @date: 2025-04-13 12:07
   */
  @Builder
  DeleteButton(id: number, index: number, type: string, title: string) {
    Column() {
      Text('删除')
        .fontColor(Color.White)
        .fontSize(16)
    }
    .justifyContent(FlexAlign.Center)
    .width(80)
    .height('100%')
    .backgroundColor(colors.warnColor)
    .onClick(() => {
      this.deleteDialogController = new CustomDialogController({
        customStyle: false,
        builder: DialogComponent({
          title: title,
          cancel: () => {
            this.deleteDialogController?.close();
          },
          confirm: () => {
            if (type === "收藏夹") {
              deleteFavoriteDirectoryService(id).then(() => {
                promptAction.showToast({
                  message: "删除收藏夹成功",
                  duration: 2000,
                  bottom: px2vp(display.getDefaultDisplaySync().height) / 2
                })
                this.myFavoriteDirectoryList.splice(index, 1);
                this.deleteDialogController?.close();
              })
            } else if (type === "歌手") {
              deleteFavoriteAuthorService(id).then((res) => {
                promptAction.showToast({
                  message: "删除歌手成功",
                  duration: 2000,
                  bottom: px2vp(display.getDefaultDisplaySync().height) / 2
                })
                this.myFavoriteAuthorList.splice(index, 1);
                this.deleteDialogController?.close();
              })
            } else {
              deleteMusicLikeService(id).then((res) => {
                promptAction.showToast({
                  message: "删除歌曲成功",
                  duration: 2000,
                  bottom: px2vp(display.getDefaultDisplaySync().height) / 2
                })
                this.myLikeMusicList.splice(index, 1);
                this.deleteDialogController?.close();
              })
            }

          },
        }),
        alignment: DialogAlignment.Center,
      })
      this.deleteDialogController.open()
    })
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
            .onClick(() => router.pushUrl({ url: 'pages/UserPage' }))
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
              })
              .rotate({ angle: this.isFoldFavoriteDirectory ? 90 : 0 })
            Text("我的歌单").margin({ left: size.pagePadding })
            Blank()
            Image($r("app.media.icon_add"))
              .width(size.smallIconSize)
              .height(size.smallIconSize)
              .onClick(this.useAddDirectory.bind(this))
          }.width('100%')

          if (!this.isFoldFavoriteDirectory) {
            Blank().height(size.pagePadding)
            List() {
              ForEach(this.myFavoriteDirectoryList, (item: FavoriteDirectoryInterface, index: number) => {
                ListItem() {
                  Row({ space: size.pagePadding }) {
                    MusicAvaterComponent({
                      avater: item.cover?.toString(),
                      title: item.name[0],
                      dimension: Number(size.middleAvaterSize),
                      type: 'music'
                    })
                    Column() {
                      Text(item.name)
                      Text((item?.total ?? 0).toString() + '首').fontColor(colors.disableTextColor)
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
                  .padding({
                    top: index !== 0 ? size.pagePadding : 0,
                    bottom: index !== this.myFavoriteDirectoryList.length - 1 ? size.pagePadding : 0
                  })
                  .border({
                    width: {
                      bottom: 1
                    },
                    color: {
                      bottom: index !== this.myFavoriteDirectoryList.length - 1 ? colors.borderColor : colors.blockColor
                    },
                    style: {
                      bottom: BorderStyle.Solid
                    }
                  })
                  .onClick(() => this.useMusicFavoriteList(item))
                }.swipeAction({
                  end: () => {
                    return this.DeleteButton(item.id, index, "收藏夹", `是否删除收藏夹${item.name}`)
                  }
                })
              })
            }
          }
        }.blockStyle()

        Column() {
          Row() {
            Image($r("app.media.icon_down"))
              .width(size.smallIconSize)
              .height(size.smallIconSize)
              .colorFilter(colors.borderColor)
              .onClick(() => {
                this.isFoldMusicLike = !this.isFoldMusicLike;
                if (!this.isFoldMusicLike) {
                  getMusicLikeService(1, 5).then((res) => {
                    this.myLikeMusicTotal = res.total;
                    this.myLikeMusicList = res.data;
                  });
                }
              })
              .rotate({ angle: this.isFoldMusicLike ? 90 : 0 })
            Text("我喜欢的歌曲").margin({ left: size.pagePadding })
            if (this.myRecordMusicTotal > 5) {
              Blank()
              Text("更多").fontColor(colors.disableTextColor).decoration({
                type: TextDecorationType.Underline,
                color: colors.disableTextColor
              }).onClick(() => {

              })
            }
            Blank()
          }.width('100%')

          if (!this.isFoldMusicLike) {
            Blank().height(size.pagePadding)
            List() {
              ForEach(this.myLikeMusicList, (item: MusicInterface, index: number) => {
                ListItem() {
                  Row() {
                    Image(getMusicCover(item.cover))
                      .width(size.middleAvaterSize)
                      .height(size.middleAvaterSize)
                      .borderRadius(size.middleAvaterSize)
                    Column() {
                      Text(item.authorName)
                    }.margin({ left: size.pagePadding }).alignItems(HorizontalAlign.Start)

                    Text(`${item.authorName} - ${item.songName}`)
                      .layoutWeight(1)
                      .textOverflow({
                        overflow: TextOverflow.Ellipsis
                      })
                      .maxLines(1)
                      .width(0)
                    Image($r("app.media.icon_music_play"))
                      .width(size.smallIconSize)
                      .height(size.smallIconSize)
                      .margin({ left: size.pagePadding })
                    Image($r("app.media.icon_music_menu"))
                      .width(size.smallIconSize)
                      .height(size.smallIconSize)
                      .margin({ left: size.pagePadding })
                  }
                  .width('100%')
                  .padding({
                    top: index !== 0 ? size.pagePadding : 0,
                    bottom: index !== this.myLikeMusicList.length - 1 ? size.pagePadding : 0
                  })
                  .border({
                    width: {
                      bottom: 1
                    },
                    color: {
                      bottom: index !== this.myLikeMusicList.length - 1 ? colors.borderColor : colors.blockColor
                    },
                    style: {
                      bottom: BorderStyle.Solid
                    }
                  })
                }.swipeAction({
                  end: () => {
                    return this.DeleteButton(item.id, index, "歌曲", `是否删除歌曲${item.songName}`)
                  }
                })
              })
            }

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
              })
              .rotate({ angle: this.isFoldFavoriteAuthor ? 90 : 0 })
            Text("我关注的歌手").margin({ left: size.pagePadding })
            if (this.myFavoriteAuthorTotal > 5) {
              Blank()
              Text("更多").fontColor(colors.disableTextColor).decoration({
                type: TextDecorationType.Underline,
                color: colors.disableTextColor
              }).onClick(() => {

              })
            }
            Blank()
          }.width('100%')

          if (!this.isFoldFavoriteAuthor) {
            Blank().height(size.pagePadding)
            List() {
              ForEach(this.myFavoriteAuthorList, (item: MusicAuthorInterface, index: number) => {
                ListItem() {
                  Row() {
                    Image(item.avatar ?
                      (/http[s]?:\/\//.test(item.avatar) ? item.avatar.replace('{size}', '480') : HOST + item.avatar) :
                    $r("app.media.default_avater"))
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
                  }
                  .width('100%')
                  .padding({
                    top: index !== 0 ? size.pagePadding : 0,
                    bottom: index !== this.myFavoriteAuthorList.length - 1 ? size.pagePadding : 0
                  })
                  .border({
                    width: {
                      bottom: 1
                    },
                    color: {
                      bottom: index !== this.myFavoriteAuthorList.length - 1 ? colors.borderColor : colors.blockColor
                    },
                    style: {
                      bottom: BorderStyle.Solid
                    }
                  })
                }.swipeAction({
                  end: () => {
                    return this.DeleteButton(item.id, index, "歌手", `是否删除歌手${item.authorName}`)
                  }
                })
              })
            }

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
              })
              .rotate({ angle: this.isFoldRecordMusic ? 90 : 0 })
            Text("我听过的歌曲").margin({ left: size.pagePadding })
            if (this.myRecordMusicTotal > 10) {
              Blank()
              Text("更多").fontColor(colors.disableTextColor).decoration({
                type: TextDecorationType.Underline,
                color: colors.disableTextColor
              }).onClick(() => {
                router.pushUrl({ url: 'pages/RecordMusicPage' })
              })
            }
          }.width('100%')

          if (!this.isFoldRecordMusic) { // 如果是展开状态
            Blank().height(size.pagePadding)
            ForEach(this.myRecordMusicList, (item: MusicInterface, index: number) => {
              Row() {
                Image(item.cover ?
                  (/http[s]?:\/\//.test(item.cover) ? item.cover.replace('{size}', '480') : HOST + item.cover) :
                $r("app.media.default_avater"))
                  .width(size.middleAvaterSize)
                  .height(size.middleAvaterSize)
                  .borderRadius(size.middleAvaterSize)
                Column() {
                  Text(item.songName)
                  Text(`听过${(item?.times ?? 0).toString()}次`).fontColor(colors.disableTextColor)
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

              if (index !== this.myRecordMusicList.length - 1) {
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