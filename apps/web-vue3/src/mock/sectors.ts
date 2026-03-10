import type { HotSector } from "../types/stock";

export const hotSectors: HotSector[] = [
  {
    id: "ai-compute",
    name: "算力",
    heat: "high",
    status: "政策和订单预期共同抬升，龙头带动明显。",
    stocks: [
      { code: "300308", name: "中际旭创", tag: "龙头" },
      { code: "300394", name: "天孚通信", tag: "高弹性" },
      { code: "603019", name: "中科曙光", tag: "核心设备" }
    ]
  },
  {
    id: "consumer-electronics",
    name: "消费电子",
    heat: "warming",
    status: "新品周期与出口修复共振，情绪正在升温。",
    stocks: [
      { code: "002475", name: "立讯精密", tag: "龙头" },
      { code: "300433", name: "蓝思科技", tag: "景气修复" },
      { code: "601138", name: "工业富联", tag: "资金关注" }
    ]
  },
  {
    id: "innovative-medicine",
    name: "创新药",
    heat: "diverging",
    status: "出海叙事仍强，但估值分歧开始放大。",
    stocks: [
      { code: "688271", name: "联影医疗", tag: "情绪强" },
      { code: "300347", name: "泰格医药", tag: "出海链" },
      { code: "600276", name: "恒瑞医药", tag: "龙头" }
    ]
  }
];
