import java.util.*;
import java.util.concurrent.*;
import java.util.stream.Collectors;




//classe Tarefa para armazenar as informações de cada tarefa:
class Tarefa {
    int id;
    int tempo;
    List<Integer> dependencias;

    public Tarefa(int id, int tempo, List<Integer> dependencias) {
        this.id = id;
        this.tempo = tempo;
        this.dependencias = dependencias;
    }
}

// a lógica principal do programa (main): 
public class Main {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        int numOperarios = scanner.nextInt();
        int numTarefas = scanner.nextInt();
        scanner.nextLine();

        List<Tarefa> tarefas = new ArrayList<>();
        for (int i = 0; i < numTarefas; i++) {
            String[] input = scanner.nextLine().split(" ");
            int id = Integer.parseInt(input[0]);
            int tempo = Integer.parseInt(input[1]);
            List<Integer> dependencias = Arrays.stream(input)
                    .skip(2)
                    .map(Integer::parseInt)
                    .collect(Collectors.toList());
            tarefas.add(new Tarefa(id, tempo, dependencias));
        }

        ExecutorService executor = Executors.newFixedThreadPool(numOperarios);
        Queue<Tarefa> fila = new LinkedList<>(tarefas);
        Set<Integer> tarefasConcluidas = new HashSet<>();

        while (!fila.isEmpty()) {
            Tarefa tarefaAtual = fila.poll();
            if (tarefasConcluidas.containsAll(tarefaAtual.dependencias)) {
                executor.submit(() -> {
                    try {
                        Thread.sleep(tarefaAtual.tempo);
                        System.out.println("tarefa " + tarefaAtual.id + " feita");
                        tarefasConcluidas.add(tarefaAtual.id);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                });
            } else {
                fila.add(tarefaAtual);
            }
        }

        executor.shutdown();
        try {
            executor.awaitTermination(Long.MAX_VALUE, TimeUnit.NANOSECONDS);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}