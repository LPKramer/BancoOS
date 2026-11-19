import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { createBrowserRouter, RouterProvider } from "react-router-dom";
import "./index.css";
import Layout from "./componentes/Layout";
import { ErroRota } from "./componentes/LimiteErro";
import { ProvedorEstado } from "./estado";
import Correcoes from "./paginas/Correcoes";
import DetalheOS from "./paginas/DetalheOS";
import Fila from "./paginas/Fila";
import Importar from "./paginas/Importar";
import Painel from "./paginas/Painel";
import Robo from "./paginas/Robo";
import Textos from "./paginas/Textos";

const rotas = createBrowserRouter([
  {
    element: <Layout />,
    errorElement: <ErroRota />,
    children: [
      { path: "/", element: <Painel /> },
      { path: "/fila", element: <Fila /> },
      { path: "/os/:id", element: <DetalheOS /> },
      { path: "/correcoes", element: <Correcoes /> },
      { path: "/robo", element: <Robo /> },
      { path: "/textos", element: <Textos /> },
      { path: "/importar", element: <Importar /> },
    ],
  },
]);

createRoot(document.getElementById("raiz")!).render(
  <StrictMode>
    <ProvedorEstado>
      <RouterProvider router={rotas} />
    </ProvedorEstado>
  </StrictMode>,
);
