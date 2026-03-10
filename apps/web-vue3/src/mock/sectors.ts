import type { HotSector } from "../types/stock";

export const hotSectors: HotSector[] = [
  {
    id: "ai-compute",
    name: "算力",
    aliases: ["算力服务", "人工智能算力", "服务器"],
    heat: "high",
    status: "政策和订单预期共同抬升，龙头带动明显。",
    summary: "当前更适合从龙头和高弹性标的里筛选，而不是盲目追整个板块。",
    highlights: ["龙头带动", "高弹性", "订单预期"],
    stocks: [
      { code: "300308", name: "中际旭创", tag: "龙头" },
      { code: "300394", name: "天孚通信", tag: "高弹性" },
      { code: "603019", name: "中科曙光", tag: "核心设备" }
    ]
  },
  {
    id: "consumer-electronics",
    name: "消费电子",
    aliases: ["电子消费", "智能终端"],
    heat: "warming",
    status: "新品周期与出口修复共振，情绪正在升温。",
    summary: "更适合沿着龙头和景气修复链找机会，阶段上不宜只看题材热度。",
    highlights: ["景气修复", "新品周期", "出口改善"],
    stocks: [
      { code: "002475", name: "立讯精密", tag: "龙头" },
      { code: "300433", name: "蓝思科技", tag: "景气修复" },
      { code: "601138", name: "工业富联", tag: "资金关注" }
    ]
  },
  {
    id: "innovative-medicine",
    name: "创新药",
    aliases: ["医药创新", "医药研发"],
    heat: "diverging",
    status: "出海叙事仍强，但估值分歧开始放大。",
    summary: "更适合在龙头和情绪强标的中找确定性，同时注意估值分化带来的回撤。",
    highlights: ["出海叙事", "估值分歧", "情绪强"],
    stocks: [
      { code: "688271", name: "联影医疗", tag: "情绪强" },
      { code: "300347", name: "泰格医药", tag: "出海链" },
      { code: "600276", name: "恒瑞医药", tag: "龙头" }
    ]
  },
  {
    id: "real-estate",
    name: "房地产",
    aliases: ["房地产开发", "地产开发", "房地产服务"],
    heat: "diverging",
    status: "政策预期与销售恢复并存，板块修复与分化同时出现。",
    summary: "更适合从财务稳健和区域优势明显的标的里筛选，不宜把板块反弹等同于全面反转。",
    highlights: ["政策博弈", "区域分化", "修复交易"],
    stocks: [
      { code: "000002", name: "万科A", tag: "龙头" },
      { code: "001979", name: "招商蛇口", tag: "稳健" },
      { code: "600048", name: "保利发展", tag: "核心央企" }
    ]
  }
];
