import MusicSearchComponent from './MusicSearchComponent';
import * as colors from '../theme/color';
import * as size from '../theme/size';
import { MusicCategoryInterface } from '../interface/Index';
import { getMusicCategoryService } from '../service/Index';
import MusicClassifyComponent from './MusicClassifyComponent';
import MusicCategoryComponent from './MusicCategoryComponent';
import MusicAuthorComponent from './MusicAuthorComponent';

@Component
export default struct MusicHomeComponent {
  @Styles
  blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({ top: size.pagePadding })
  }

  @State allClassifyList: Array<MusicCategoryInterface> = [];
  @State pageNum: number = 3;
  scroller: Scroller = new Scroller();

  aboutToAppear() {
    getMusicCategoryService().then((res) => {
      this.allClassifyList = res.data;
    });
  }

  build() {
    Column() {
      Scroll(this.scroller) {
        Column() {
          MusicSearchComponent()
          MusicCategoryComponent()
          ForEach(this.allClassifyList.slice(0, this.pageNum), (item: MusicCategoryInterface) => {
            if (item.category === '推荐歌手') {
              MusicAuthorComponent()
            } else {
              MusicClassifyComponent({ classifyId: Number(item.id), classifyName: item.category.toString() })
            }
          })
          Row() {
            Text(this.pageNum == this.allClassifyList.length ? '已经到底了...' : '正在加载更多...')
          }.padding({ top: size.pagePadding, bottom: size.pagePadding })
        }
      }
      .scrollable(ScrollDirection.Vertical)
      .onScrollEdge((side: Edge) => {
        if (this.pageNum < this.allClassifyList.length) {
          this.pageNum++;
        }
      }) // 滚动方向纵向
    }
    .width('100%')
    .height('100%')
    .backgroundColor(colors.pageBackgroundColor)
    .padding({ left: size.pagePadding, right: size.pagePadding, })
  }
}