import * as colors from '../theme/color';
import * as size from '../theme/size';
import router from '@ohos.router';

@Component
export default struct MusicCategoryComponent{
  @Styles blockStyle(){
    .backgroundColor(colors.white)
    .borderRadius(size.middleBorderRaduis)
    .padding(size.middleGap)
    .width('100%')
    .margin({top:size.middleGap})
  }

  build(){
    // 两行四列的网格布局，每行 4 个分类入口
    Column({space:size.middleGap}){
      Row(){
        this.useCategoryItem($r('app.media.icon_music_singer'), '歌手', 'pages/MusicAuthorCategoryPage', 0)
        this.useCategoryItem($r('app.media.icon_music_classify'), '分类歌曲', 'pages/MusicCategoryPage', 0)
        this.useCategoryItem($r('app.media.icon_music_classics'), '经典老歌', 'pages/MusicClassifyListPage', 2)
        this.useCategoryItem($r('app.media.icon_music_rank'), '热门歌曲', 'pages/MusicClassifyListPage', 1)
      }.width('100%')
      Row(){
        this.useCategoryItem($r('app.media.icon_music_viper'), '蝰蛇母带', 'pages/MusicClassifyListPage', 3)
        this.useCategoryItem($r('app.media.icon_music_exclusive'), '专属好歌', 'pages/MusicClassifyListPage', 4)
        this.useCategoryItem($r('app.media.icon_music_memory'), '音乐记忆', 'pages/MusicClassifyListPage', 5)
        this.useCategoryItem($r('app.media.icon_music_popular'), '流行热歌', 'pages/MusicClassifyListPage', 6)
      }.width('100%')
    }.blockStyle()
  }

  /**
   * @description: 分类入口（图标 + 名称），点击跳转
   * @param img 图标
   * @param label 分类名称
   * @param url 目标页面
   * @param classifyId 分类id，大于 0 时按 MusicClassifyListPage 的约定传 { musicClassify: { id, category } }
   * @date: 2026-11-18 23:20
   * @author wuwenqiang
   */
  @Builder useCategoryItem(img: Resource, label: string, url: string, classifyId: number){
    Column(){
      Image(img)
        .width(size.bigIcon * 1.5)
        .height(size.bigIcon * 1.5)
        .margin({bottom:size.middleGap})
      Text(label)
    }.width('25%').alignItems(HorizontalAlign.Center)
    .onClick(()=>{
      if (classifyId > 0) {
        router.pushUrl({
          url: url, // 目标url
          params: {
            musicClassify: { id: classifyId, category: label }
          }
        });
      } else {
        router.pushUrl({ url: url }); // 歌手、分类歌曲不需要传参
      }
    })
  }
}
