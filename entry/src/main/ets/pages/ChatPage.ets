import * as colors from '../theme/color';
import * as size from '../theme/size';
import router from '@ohos.router';
import { LIKE_INNER_EVENT } from '../common/config';
import emitter from '@ohos.events.emitter';
import { ChatHistoryInterface, ChatModelInterface, ChatType, GroupedByTimeAgoInterface } from '../interface/Index';
import { getModelListService, getChatHistoryService } from '../service/Index';
import { PositionEnum } from '../common/enum';
import AvaterComponent from "../components/AvaterComponent";
import { PAGE_SIZE } from '../common/constant';
import { formatTimeAgo, generateSecureID } from "../utils/common";

@Entry
@Component
export default struct ChatPage {
  @State modelList:Array<ChatModelInterface> = []
  @State activeModel:ChatModelInterface | null = null;
  @State prompt:string = "";// 提示词
  @State chatId:string = "";
  @State loading:boolean = false;
  @State showHistory:boolean = false;
  @State pageNum:number = 1;
  @State total:number = 0;
  @State chatList:Array<ChatType> = [
    {
      type:"tip",
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

  useChatHistory(){
    getChatHistoryService(this.pageNum,PAGE_SIZE).then((res)=>{
      res.data.forEach((aItem)=>{
        const result: GroupedByTimeAgoInterface = {};
        aItem.timeAgo = formatTimeAgo(aItem.createTime);

        // 初始化timeAgo分组
        if (!result[aItem.timeAgo]) {
          result[aItem.timeAgo] = {};
        }

        // 初始化chatId分组
        if (!result[aItem.timeAgo][aItem.chatId]) {
          result[aItem.timeAgo][aItem.chatId] = [];
        }

        // 添加消息到对应分组
        result[aItem.timeAgo][aItem.chatId].push(aItem);
      })
    })
  }

  build() {
    Stack(){
      if(this.showHistory){
        Row(){
          Column(){

          }
          .width("70%")
          .backgroundColor(colors.blockColor)
          .height("100%")
          Row()
            .height("100%")
            .layoutWeight(1)
            .backgroundColor(colors.tabNormalColor)
            .opacity(0.5)
            .onClick(()=>{
              this.showHistory = false
            })
        }
        .height("100%")
        .width("100%")
        .zIndex(1)
      }
      Column() {
        Row(){
          Image($r('app.media.icon_back'))
            .width(size.smallIconSize)
            .height(size.smallIconSize)
            .opacity(size.opacity)
            .onClick(()=>{
              router.back()
            })
          Text("当前接入模型：" + (this.activeModel?.modelName??"")).layoutWeight(1).textAlign(TextAlign.Center)
          Image($r('app.media.icon_menu'))
            .width(size.smallIconSize)
            .height(size.smallIconSize)
            .opacity(size.opacity)
            .onClick(()=>{
              this.showHistory = true;
              this.pageNum = 1;
              getChatHistoryService(this.pageNum,PAGE_SIZE).then((res)=>{

              })
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
                      Text(item.text)
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
                }
                .alignItems(VerticalAlign.Top)
                .width("100%")
                .height("100%")
              }

            })

          }

        }
        .padding(size.pagePadding)
        .align(Alignment.Top)
        .scrollable(ScrollDirection.Vertical)
        .layoutWeight(1)
        Row({space:size.pagePadding}){
          Image($r("app.media.icon_chat"))
            .opacity(size.opacity)
            .width(size.middlIconSize)
            .height(size.middlIconSize)
            .onClick(()=>{
              this.chatId = "";
            })
          Row() {
            TextInput({
              text: this.prompt,
              placeholder: "有问题，尽管问"
            })
              .height(size.middleAvaterSize)
              .layoutWeight(1)
              .backgroundColor(Color.Transparent)
              .onChange((value) => {
                this.prompt = value.trim();
              })

            if (this.prompt) {
              Image($r('app.media.icon_clear'))
                .width(size.smallIconSize)
                .height(size.smallIconSize)
                .onClick(() => {
                  this.prompt = '';
                })
                .margin({ right: size.pagePadding })
                .onClick(() => {
                  this.prompt = '';
                })
            }
          }
          .borderRadius(size.middleAvaterSize)
          .backgroundColor(colors.pageBackgroundColor)
          .layoutWeight(1)
          Row(){
            if(this.loading){
              Row()
                .height(size.smallIconSize)
                .width(size.smallIconSize)
                .backgroundColor(colors.disableTextColor)
                .borderRadius(size.smallBorderRaduis/2)
            }else{
              Image($r("app.media.icon_send"))
                .opacity(size.opacity)
                .width(size.middlIconSize)
                .height(size.middlIconSize)
            }

          }
          .width(size.middleAvaterSize)
          .height(size.middleAvaterSize)
          .borderRadius(size.middleAvaterSize)
          .backgroundColor(colors.pageBackgroundColor)
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
        }
        .backgroundColor(colors.blockColor)
        .padding(size.pagePadding)
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(colors.pageBackgroundColor)

    }.width("100%").height("100%")
  }
}