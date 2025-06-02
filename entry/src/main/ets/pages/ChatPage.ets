import * as colors from '../theme/color';
import * as size from '../theme/size';
import router from '@ohos.router';
import { LIKE_INNER_EVENT } from '../common/config';
import emitter from '@ohos.events.emitter';
import { ChatModelInterface, ChatType } from '../interface/Index';
import { getModelListService, getChatHistoryService } from '../service/Index';
import { PositionEnum } from '../common/enum';
import AvaterComponent from "../components/AvaterComponent";
@Entry
@Component
export default struct ChatPage {
  @State modelList:Array<ChatModelInterface> = []
  @State activeModel:ChatModelInterface | null = null;
  @State chatList:Array<ChatType> = [
    {
      text:"你好，我是智能音乐助手小吴同学，请问有什么可以帮助您？",
      position:PositionEnum.LEFT,
    }
  ];
  aboutToAppear() {
    getModelListService().then((res)=>{
      this.modelList = res.data;
      this.activeModel = res.data[0];
    })
  }

  aboutToDisappear() {
    emitter.off(LIKE_INNER_EVENT.eventId);
  }

  build() {
    Column() {
      Row(){
        Image($r('app.media.icon_back'))
          .width(size.smallIconSize)
          .height(size.smallIconSize)
          .opacity(size.opacity)
          .onClick(()=>{
            router.back()
          })
        Text(this.activeModel?.modelName).layoutWeight(1).textAlign(TextAlign.Center)
        Image($r('app.media.icon_menu'))
          .width(size.smallIconSize)
          .height(size.smallIconSize)
          .opacity(size.opacity)
          .onClick(()=>{

          })
      }
      .alignItems(VerticalAlign.Center)
      .padding(size.pagePadding)
      .backgroundColor(colors.blockColor)


      Scroll() {
        Column({space:size.pagePadding}){
          ForEach(this.chatList,(item:ChatType)=>{
            if(item.position == PositionEnum.LEFT){
              Row(){
                Image($r("app.media.icon_ai"))
                  .width(size.middlIconSize)
                  .height(size.middlIconSize)
                  .margin({right:size.smallIconSize})
                Stack(){
                  Image($r("app.media.icon_triangle"))
                    .width(size.smallIconSize)
                    .height(size.smallIconSize)
                    .alignSelf(ItemAlign.Start)
                    .position({x:-size.smallIconSize/1.5,y:size.smallIconSize/2})
                  Row(){
                    Text("你好，我是智能音乐助手小吴同学，请问有什么可以帮助您？")
                  }
                  .backgroundColor(colors.blockColor)
                  .borderRadius(size.blockBorderRaduis)
                  .padding(size.pagePadding)
                }.layoutWeight(1)
              }.alignItems(VerticalAlign.Top)
            }else{
              Row(){
                Stack(){
                  Image($r("app.media.icon_triangle"))
                    .width(size.smallIconSize)
                    .height(size.smallIconSize)
                    .alignSelf(ItemAlign.Start)
                    .rotate({ angle: 180 })
                    .position({right:-size.smallIconSize/1.5,top:size.smallIconSize/2})
                  Row(){
                    Text(item.text)
                  }
                  .backgroundColor(colors.blockColor)
                  .borderRadius(size.blockBorderRaduis)
                  .padding(size.pagePadding)
                }.layoutWeight(1)

                AvaterComponent({dimensions:size.middlIconSize}).margin({left:size.smallIconSize})
              }.alignItems(VerticalAlign.Top)
            }

          })

        }

      }
      .padding(size.pagePadding)
      .align(Alignment.Top)
      .scrollable(ScrollDirection.Vertical)
      .layoutWeight(1)
      Row({space:size.pagePadding}){
        Image($r("app.media.icon_user")).width(size.middlIconSize).height(size.middlIconSize)
      }
      .padding(size.pagePadding)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(colors.pageBackgroundColor)
  }
}