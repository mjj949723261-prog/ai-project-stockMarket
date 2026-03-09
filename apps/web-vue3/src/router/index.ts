import { createRouter, createWebHashHistory } from "vue-router";
import HomeView from "../views/HomeView.vue";
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
      path: "/watchlist",
      name: "watchlist",
      component: WatchlistView
    }
  ]
});

