import * as colors from '../theme/color';
import * as size from '../theme/size';
import {
  MusicStorageInterface,
  FavoriteDirectoryInterface,
  MusicInterface,
  MusicCategoryInterface
} from '../interface/Index';
import { MUSIC_STORAGE, PAGE_SIZE } from '../common/constant';
import { getMusicCategoryService, getMusicListByCategoryIdService } from '../service/Index';
import { useAppStorage, usePlayerRouter } from '../utils/common';
import NavigatorTitleComponent from '../components/NavigatorTitleComponent';
import MusicClassifyListComponent from '../components/MusicClassifyListComponent';

@Entry
@Component
export default struct MusicCategoryPage {
  @StorageLink(MUSIC_STORAGE) musicStorage: MusicStorageInterface = useAppStorage()
  @State favoriteDirectory: FavoriteDirectoryInterface | null = null;
  @State allCategoryList: Array<Array<MusicCategoryInterface>> = [];
  @State currentCategoryList: Array<Array<MusicCategoryInterface>> = [];
  @State musicList: Array<MusicInterface> = [];
  @State activeCategory: MusicCategoryInterface = {} as MusicCategoryInterface;
  @State pageNum: number = 1;
  @State total: number = 0;
  @State loading: boolean = false;
  @State expand: boolean = false;

  @Styles
  blockStyle(){
    .backgroundColor(colors.white)
    .borderRadius(size.middleBorderRaduis)
    .padding(size.middleGap)
    .width('100%')
    .margin({ top: size.middleGap })
  }

  @Styles
  arrowIconStyle(){
    .width(size.smallIcon)
    .height(size.smallIcon)
  }

  aboutToAppear() {
    getMusicCategoryService().then((res) => {
      for (let i = 0; i < Math.ceil(res.data.length / 3); i++) {
        const categoryList: Array<MusicCategoryInterface> = [];
        for (let j = 0; j < 3; j++) {
          categoryList.push(res.data[i * 3 + j < res.data.length ? i * 3 + j : 0])
        }
        this.allCategoryList.push(categoryList);
      }
      this.currentCategoryList.push(...this.allCategoryList.slice(0, 3));
      this.activeCategory = this.currentCategoryList[0][0];
      this.useMusicList();
    });
  }

  /**
   * @description: 获取歌手列表
   * @date: 2024-08-20 00:15
   * @author wuwenqiang
   */
  useMusicList() {
    if (this.loading) {
      return;
    }
    this.loading = true;
    getMusicListByCategoryIdService(this.activeCategory.id, this.pageNum, PAGE_SIZE).then((res) => {
      this.total = res.total;
      this.musicList.push(...res.data);
    }).finally(() => {
      this.loading = false;
    });
  }

  /**
   * @description: 播放音乐分类
   * @date: 2024-07-17 22:23
   * @author wuwenqiang
   */
  async usePlayMusicList(musicModel: MusicInterface, index: number) {
    let musicList: Array<MusicInterface> = [];
    if (this.musicStorage.classifyName !== this.activeCategory.category) {
      musicList = await getMusicListByCategoryIdService(this.activeCategory.id, 1, 500).then(res => res.data)
    }
    usePlayerRouter(this.musicStorage, musicList, musicModel, this.activeCategory.category, index)
  }

  build() {
    Column() {
      NavigatorTitleComponent({ title: '歌手分类' })
      Scroll() {
        Column() {
          Column({ space: size.smallGap }) {
            ForEach(this.currentCategoryList, (items: Array<MusicCategoryInterface>) => {
              Row({ space: size.smallGap }) {
                ForEach(items, (item: MusicCategoryInterface) => {
                  if (item) {
                    Text(item.category)
                      .border({
                        width: 1,
                        color: this.activeCategory?.id === item.id ? colors.primary : colors.borderColor,
                        style: BorderStyle.Solid
                      })
                      .onClick(() => {
                        if (this.activeCategory?.id === item.id) {
                          return;
                        }
                        this.activeCategory = item;
                        this.musicList = [];
                        this.total = 0;
                        this.useMusicList();
                      })
                      .fontColor(this.activeCategory?.id === item.id ? colors.primary :
                      colors.black)
                      .layoutWeight(1)
                      .textAlign(TextAlign.Center)
                      .height(size.inputHeight)
                      .borderRadius(size.smallBorderRaduis)
                  } else {
                    Text('').layoutWeight(1).visibility(Visibility.Hidden)
                  }
                })
              }
            })
            Row() {
              Text(this.expand ? '收起' : '展开更多').fontColor(colors.gray)
              Image($r('app.media.icon_arrow'))
                .opacity(size.opacity)
                .arrowIconStyle()
                .rotate({ angle: this.expand ? 90 : 0 })
            }
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
              this.expand = !this.expand;
              this.currentCategoryList.splice(0, this.currentCategoryList.length,
                ...this.allCategoryList.slice(0, this.expand ? this.allCategoryList.length : 3));
            })
          }
          .blockStyle()

          MusicClassifyListComponent({
            musicList: $musicList,
            classifyName: this.activeCategory?.category,
            onPlayMusicList: this.usePlayMusicList,
          })

          Row() {
            Text(this.pageNum * PAGE_SIZE < this.total || this.loading ? '正在加载更多...' : '已经到底了...')
          }.width('100%').justifyContent(FlexAlign.Center).padding({ top: size.middleGap, bottom: size.middleGap })
        }
        .justifyContent(FlexAlign.Start)
      }
      .onScrollEdge((side: Edge) => {
        if (this.pageNum * PAGE_SIZE < this.total) {
          this.pageNum++;
          this.useMusicList()
        }
      })
      .padding({ left: size.middleGap, right: size.middleGap })
      .align(Alignment.Top)
      .scrollable(ScrollDirection.Vertical)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(colors.pageBackground)
  }
}