import * as colors from '../theme/color';
import * as size from '../theme/size';
import { FavoriteDirectoryInterface } from '../interface/Index';
import { insertFavoriteDirectoryService } from '../service/Index';
import promptAction from '@ohos.promptAction';
import display from '@ohos.display';

@Component
export default struct CreateFavoriteDirectory {
  @State checkboxValue: Array<number> = [];
  @State favoriteDirectoryList: Array<FavoriteDirectoryInterface> = [];
  @State favoriteName: string = '';
  public onCreateDirectory: (favoriteDirectory: FavoriteDirectoryInterface) => void = () => {
  };
  public onCancleCreateDirectory: () => void = () => {
  };

  build() {
    Column({ space: size.middleGap }) {
      Row() {
        Text('*').fontColor(Color.Red)
        Text('名称')
        TextInput({ text: this.favoriteName, placeholder: '请输入收藏夹名称' })
          .height(size.middleAvater)
          .backgroundColor(colors.pageBackground)
          .borderRadius(size.smallBorderRaduis)
          .margin({ left: size.middleGap })
          .onChange((value) => {
            this.favoriteName = value.trim();
          })
          .layoutWeight(1)
      }
      .width('100%')

      Row() {
        Text('*').visibility(Visibility.Hidden)
        Text('封面')
        Row() {
          Image($r('app.media.icon_add'))
            .width(size.middleIcon)
            .aspectRatio(1)
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .backgroundColor(colors.pageBackground)
        .borderRadius(size.smallBorderRaduis)
        .margin({ left: size.middleGap })
        .width(size.bigAvater)
        .aspectRatio(1)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Button('创建')
        .width('100%')
        .padding(size.middleGap)
        .backgroundColor(colors.warn)
        .fontColor(Color.White)
        .borderRadius(size.middleBorderRaduis * 2)
        .onClick(() => {
          const favoriteDirectory: FavoriteDirectoryInterface = {
            name: this.favoriteName,
          }
          insertFavoriteDirectoryService(favoriteDirectory).then(res => {
            promptAction.showToast({
              message: '创建收藏夹成功',
              duration: 2000,
              bottom: px2vp(display.getDefaultDisplaySync().height) / 2
            })
            this.onCreateDirectory(res.data);
          });
        })

      Button('取消')
        .width('100%')
        .padding(size.middleGap)
        .border({ width: 1, color: colors.borderColor })
        .backgroundColor(Color.Transparent)
        .fontColor(Color.Black)
        .borderRadius(size.middleBorderRaduis * 2)
        .onClick(() => {
          this.onCancleCreateDirectory()
        })
    }.padding(size.middleGap)
  }
}