import { createRouter, createWebHashHistory } from "vue-router";
import HomeView from "../views/HomeView.vue";
import HotView from "../views/HotView.vue";
import NewsDetailView from "../views/NewsDetailView.vue";
import SectorDetailView from "../views/SectorDetailView.vue";
import StockDetailView from "../views/StockDetailView.vue";
import WatchlistView from "../views/WatchlistView.vue";

export default createRouter({
  history: createWebHashHistory(),
  routes: [
    {
      path: "/",
      name: "home",
      component: HomeView
    },
    {
      path: "/stocks/:code",
      name: "stock-detail",
      component: StockDetailView
    },
    {
      path: "/hot",
      name: "hot",
      component: HotView
    },
    {
      path: "/sectors/:id",
      name: "sector-detail",
      component: SectorDetailView
    },
    {
      path: "/news/:id",
      name: "news-detail",
      component: NewsDetailView
    },
    {
      path: "/watchlist",
      name: "watchlist",
      component: WatchlistView
    }
  ]
});
