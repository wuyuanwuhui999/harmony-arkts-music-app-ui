import * as colors from '../theme/color';
import * as size from '../theme/size';

@CustomDialog
export default struct CommentInputComponent {
  @State text: string = '';
  placeholder: string = '评论';
  onSend: (value: string) => void = () => {
  }
  controller: CustomDialogController;

  build() {
    Column() {
      Blank().layoutWeight(1).onClick(() => {
        this.controller.close()
      })
      Row() {
        TextInput({ placeholder: this.placeholder, })
          .layoutWeight(1)
          .height(size.inputHeight)
          .onChange((value) => {
            this.text = value;
          })
        Button('发送', { type: ButtonType.Capsule, stateEffect: true })
          .backgroundColor(colors.primary)
          .width(size.btnWidth)
          .enabled(Boolean(this.text))
          .height(size.inputHeight)
          .margin({ left: size.middleGap })
          .onClick(() => {
            this.onSend(this.text);
          })
      }.backgroundColor(colors.white).padding(size.middleGap)
    }
    .height('100%')
    .width('100%')
  }
}