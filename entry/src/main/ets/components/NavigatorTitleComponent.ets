import * as colors from '../theme/color';
import * as size from '../theme/size';
import router from '@ohos.router';

@Component
export default struct NavigatorTitleComponent {
  @Prop title: string;

  build() {
    Row(){
      Image($r('app.media.icon_back'))
        .width(size.smallIcon)
        .height(size.smallIcon)
        .opacity(size.opacity)
        .onClick(()=>{
          router.back()
        })
      Text(this.title)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      Image($r('app.media.icon_back'))
        .width(size.smallIcon)
        .height(size.smallIcon)
        .visibility(Visibility.Hidden)
    }
    .width('100%')
    .padding(size.middleGap)
    .backgroundColor(colors.white)
  }
}