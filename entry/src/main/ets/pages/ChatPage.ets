import * as colors from '../theme/color';
import * as size from '../theme/size';
import router from '@ohos.router';
import { LIKE_INNER_EVENT } from '../common/config';
import emitter from '@ohos.events.emitter';
import { ChatModelInterface, ChatInterface, GroupedByChatIdInterface, GroupedByTimeAgoInterface,
  ChatHistoryInterface,
  ChatParamsInterface} from '../interface/Index';
import { getModelListService, getChatHistoryService } from '../service/Index';
import { PositionEnum } from '../common/enum';
import AvaterComponent from "../components/AvaterComponent";
import { HOST, PAGE_SIZE } from '../common/constant';
import { formatTimeAgo, generateSecureID } from "../utils/common";
import { display, promptAction } from '@kit.ArkUI';
import webSocket from '@ohos.net.webSocket';
import { BusinessError } from '@kit.BasicServicesKit';
import api from '../api';
import preference from '../utils/PreferenceModel';

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
  @State chatHistoryGroup:GroupedByTimeAgoInterface = {};
  @State token:string = "";
  @State chatList:Array<ChatInterface> = [
    {
      type:"tip",
      text:"你好，我是智能音乐助手小吴同学，请问有什么可以帮助您？",
      position:PositionEnum.LEFT,
    }
  ];
  @State message: string = '';
  private ws: webSocket.WebSocket | null = null;

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
    const chatHistoryGroup:GroupedByTimeAgoInterface = JSON.parse(JSON.stringify(this.chatHistoryGroup))
    getChatHistoryService(this.pageNum,PAGE_SIZE).then((res)=>{
      this.total = res.total
      const result:GroupedByChatIdInterface = {}
      res.data.forEach((aItem)=>{
        aItem.timeAgo = formatTimeAgo(aItem.createTime);
        if(!result[aItem.chatId]){
          result[aItem.chatId] = [];
        }
        result[aItem.chatId].push(aItem);
      });

      const keys:string[] = Object.keys(result);
      keys.forEach((key)=>{
        const timeAgo = result[key][0].timeAgo;
        if(!chatHistoryGroup[timeAgo]){
          chatHistoryGroup[timeAgo] = [];
        }
        chatHistoryGroup[timeAgo].push(result[key])
      });
      this.chatHistoryGroup = chatHistoryGroup;
    })
  }

  onSend=()=>{
    if(this.prompt === ""){
      promptAction.showToast({
        message: "请输入要问的问题",
        duration: 2000,
        bottom: px2vp(display.getDefaultDisplaySync().height) / 2
      })
    }else{

    }
  }

  // 建立WebSocket连接
  async buildConnection() {
    if(!this.ws){
      await this.connectWebSocket();
    }
    if(this.token) this.token = await preference.getToken() as string;
    this.chatId = this.chatId || generateSecureID();
    const payload:ChatParamsInterface = {
      modelId:"qwen3:8b",
      token: this.token, // 替换为实际用户ID
      chatId:this.chatId, // 替换为实际聊天ID
      prompt: this.prompt.trim(),
      files: [] // 如果需要上传文件，请根据实际情况调整
    };
    this.ws?.send(JSON.stringify(payload),()=>{

    })
  }

  connectWebSocket():Promise<string>{
    return new Promise((resolve,reject)=>{
      const url = `wss://${HOST}${api.chatWs}`; // 替换为实际API地址
      this.ws = webSocket.createWebSocket();

      // 设置事件监听
      this.ws.on('open', () => {
        resolve('')
      });
      this.ws.on('message', (error: BusinessError,data: string | ArrayBuffer) => {
        if (typeof data === 'string') {
          this.message += data;
        }
      });
      this.ws.on('close', () => console.log('连接关闭'));
      this.ws.on('error', (err: Error) => console.error('错误:', err));
      // 发起连接
      this.ws.connect(url);
    });
  }

  build() {
    Stack(){
      if(this.showHistory){
        Row(){
          Scroll(){
            Column({space:size.pagePadding}){
              ForEach(Object.keys(this.chatHistoryGroup),(key:string)=>{
                Column({space:size.miniPadding}){
                  Text(key).fontColor(colors.disableTextColor)
                  ForEach(this.chatHistoryGroup[key],(item:ChatHistoryInterface[])=>{
                    Text(item[0].prompt)
                      .maxLines(1) // 限制最大行数为1
                      .textOverflow({ overflow: TextOverflow.Ellipsis }) // 溢出时显示省略号
                      .width('100%') // 必须设置宽度（或固定宽度）触发溢出判断
                  })
                }.alignItems(HorizontalAlign.Start)
              })
            }.alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.Start)
          }
          .onScrollEdge((side: Edge) => {
            if (this.total > this.pageNum * PAGE_SIZE) {
              this.pageNum++;
              this.useChatHistory();
            }
          })
          .align(Alignment.TopStart)
          .padding(size.pagePadding)
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
              this.chatHistoryGroup = {};
              this.useChatHistory();
            })
        }
        .alignItems(VerticalAlign.Center)
        .padding(size.pagePadding)
        .backgroundColor(colors.blockColor)
        Scroll() {
          Column({space:size.pagePadding}){
            ForEach(this.chatList,(item:ChatInterface)=>{
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
                .onClick(this.onSend)
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