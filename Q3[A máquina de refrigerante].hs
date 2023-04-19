import Control.Concurrent
import Control.Concurrent.MVar
import Control.Monad
import Text.Printf

data Bebida = PepiseCola | GuaranáPoloNorte | GuaranáQuate deriving (Show, Eq)

type Maquina = MVar (Int, Int, Int)

main :: IO ()
main = do
  maquina <- newMVar (2000, 2000, 2000)
  lock <- newMVar ()
  let clientesPepise = 3
      clientesPoloNorte = 2
      clientesQuate = 4

  forM_ [1 .. clientesPepise] $ \n ->
    forkIO $ simulacao lock n PepiseCola maquina

  forM_ [1 .. clientesPoloNorte] $ \n ->
    forkIO $ simulacao lock n GuaranáPoloNorte maquina

  forM_ [1 .. clientesQuate] $ \n ->
    forkIO $ simulacao lock n GuaranáQuate maquina

  threadDelay 30000000

simulacao :: MVar () -> Int -> Bebida -> Maquina -> IO ()
simulacao lock clienteId bebida maquina = forever $ do
  threadDelay 1000000
  withMVar lock $ \_ -> do
    putStrLn $ printf "O cliente %d do refrigerante %s está enchendo seu copo" clienteId (show bebida)
  abastece lock bebida maquina

abastece :: MVar () -> Bebida -> Maquina -> IO ()
abastece lock bebida maquina = do
  (pc, pn, q) <- takeMVar maquina
  let limite = 1000
  if (bebida == PepiseCola && pc < limite)
    || (bebida == GuaranáPoloNorte && pn < limite)
    || (bebida == GuaranáQuate && q < limite)
    then do
      threadDelay 1500000
      let novoEstado = case bebida of
            PepiseCola -> (pc + 1000, pn, q)
            GuaranáPoloNorte -> (pc, pn + 1000, q)
            GuaranáQuate -> (pc, pn, q + 1000)
      putMVar maquina novoEstado
      withMVar lock $ \_ -> do
        putStrLn $ printf "O refrigerante %s foi reabastecido com 1000 ml, e agora possui %d ml" (show bebida) (quantidade novoEstado)
    else putMVar maquina (pc - 300, pn - 300, q - 300)

quantidade :: (Int, Int, Int) -> Int
quantidade (pc, pn, q) = case bebida of
  PepiseCola -> pc
  GuaranáPoloNorte -> pn
  GuaranáQuate -> q
  where
    bebida = if pc < pn then (if pn < q then GuaranáQuate else GuaranáPoloNorte) else (if pc < q then GuaranáQuate else PepiseCola)